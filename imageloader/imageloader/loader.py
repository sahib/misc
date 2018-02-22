#!/usr/bin/env python3
# encoding: utf8

"""Small image downloading utilty.

Usage:

    $ python image-downloader.py [list-of-urls]
"""

import os
import sys
import socket
import logging
import hashlib
import urllib.request

from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor


def read_urllist(path):
    """Read a list of urls from the file at `path`"""
    try:
        with open(path, 'r') as handle:
            return parse_urllist(handle)
    except OSError as err:
        logging.warning('Failed to open %s: %s', path, err)
        return []


def parse_urllist(handle):
    """Parses a list of urls from the filedescriptor pointed to by `handle`"""
    # Skip empty lines, if any; might also filter comments here:
    return list(filter(None, map(str.strip, handle)))


def basename_from_url(url):
    """Attempts to guess the basename of the saved file from the image url"""
    *_, last = os.path.split(urlparse(url).path)
    if len(last) == 0:
        raise ValueError('Empty URL: ' + url)

    # Watch out for things like '..' and '.' if present.
    # Might become a problem if joined to a path.
    if last == '.' or last == '..':
        raise ValueError('Incompatible path')

    return last


def save_image(basedir, url, content):
    """Save `content` from `url` to the images/ subdir of `basedir`"""
    # Deduplicate the downloaded images automatically:
    suffix = hashlib.sha256(content).hexdigest()
    data_path = os.path.join(basedir, 'images/by-hash', suffix)
    link_path = os.path.join(basedir, 'images/by-name', basename_from_url(url))

    try:
        for name in ['by-name', 'by-hash']:
            os.makedirs(os.path.join(basedir, 'images', name), exist_ok=True)

        with open(data_path, 'wb') as handle:
            handle.write(content)
    except OSError as err:
        logging.warning('Failed to save %s to %s: %s', url, data_path, err)
        return

    # Hardlinks are not very portable, but I assume it runs on Linux:
    try:
        os.link(data_path, link_path)
    except FileExistsError:
        pass


def download_image(url, timeout=5):
    """Download the image at `url`, waiting at most `timeout` secs"""

    # Note: This does not check if the URL is really an image (by looking at
    # the mime type), or if the image changed compared to last time (by
    # comparing the mtime of the local file to HTTP's Last-Modified).  Both
    # changes would be probably a good idea (depending on the usecase) but were
    # left out for brevity. Both need a HEAD before the GET.
    try:
        response = urllib.request.urlopen(url, timeout=timeout)
    except ValueError:
        logging.warning('Bad URL: ' + url)
        return '', None
    except (socket.timeout, urllib.error.HTTPError, urllib.error.URLError):
        return url, None

    try:
        data = response.read()
    except OSError as err:
        logging.warning('Failed to download `%s`: %s', url, err)

    return url, data


def download_images(urls, max_workers=10):
    """Downloads all images in `urls` and saves them to local storage"""
    # Images may be large, so watch out to keeping the parallel downloads low.
    # If this poses to be a problem, one might also stream the image directly
    # to the filesystem without much buffering in memory.
    cwd = os.getcwd()

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for (url, content) in executor.map(download_image, urls):
            if content is not None:
                logging.info('-- Downloaded %s', url)
                save_image(cwd, url, content)


def main():
    """Handle the very primitive commandline interface"""
    # Future versions should provide some options for setting the timeout,
    # the directory name to be created and so on. Left out for brevity.
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    urls = read_urllist(sys.argv[1])
    if len(urls) > 0:
        download_images(urls)


if __name__ == '__main__':
    main()
