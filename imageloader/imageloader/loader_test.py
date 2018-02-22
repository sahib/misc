#!/usr/bin/env python3
# encoding: utf8

import os
import io
import time
import shutil
import unittest
import tempfile

from threading import Thread
from http.server import BaseHTTPRequestHandler, HTTPServer

import loader as ld


# This would be probably easier with the Requests library,
# but I decided to stick with the standard python library for now.
# (also standard unittest instead of nosetests)
class MockHTTPHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == '/404':
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'not found')
            return

        if self.path == '/wait':
            time.sleep(2)

        self.send_response(200)
        self.send_header('Content-type', 'image/png')
        self.end_headers()

        content = 'dummy@' + self.path + '\n'

        try:
            self.wfile.write(content.encode())
        except BrokenPipeError:
            pass


class TestParseUrllist(unittest.TestCase):

    def test_base(self):
        self.assertEqual(
            ld.parse_urllist(io.StringIO('a\nb\nc\n')),
            ['a', 'b', 'c']
        )

    def test_empty(self):
        self.assertEqual(
            ld.parse_urllist(io.StringIO('')),
            []
        )
        self.assertEqual(
            ld.parse_urllist(io.StringIO('\n\n')),
            []
        )


class TestBasenameFromURL(unittest.TestCase):

    def test_base(self):
        self.assertEqual(
            ld.basename_from_url('https://x.com/a'),
            'a'
        )
        self.assertEqual(
            ld.basename_from_url('https://x.com/a/b'),
            'b'
        )
        self.assertEqual(
            ld.basename_from_url('https://x.com/a/b.'),
            'b.'
        )

    def test_bad_input(self):
        with self.assertRaises(ValueError):
            ld.basename_from_url('')

        with self.assertRaises(ValueError):
            ld.basename_from_url('https://x.com/..')

        with self.assertRaises(ValueError):
            ld.basename_from_url('https://x.com/.')


class TestSaveImage(unittest.TestCase):

    def setUp(self):
        self._basedir = tempfile.mkdtemp(suffix='-pytest')

    def tearDown(self):
        shutil.rmtree(self._basedir)

    def test_base(self):
        ld.save_image(self._basedir, 'http://x.com/1.jpg', b'data')
        ld.save_image(self._basedir, 'http://x.com/2.jpg', b'data')

        files = os.listdir(os.path.join(self._basedir, 'images/by-hash'))
        self.assertEqual(len(files), 1)

        files = os.listdir(os.path.join(self._basedir, 'images/by-name'))
        self.assertEqual(sorted(files), ['1.jpg', '2.jpg'])


class TestDownloadImage(unittest.TestCase):

    def setUp(self):
        self._server = HTTPServer(('', 8080), MockHTTPHandler)
        self._thread = Thread(target=self._server.serve_forever)
        self._thread.start()
        # Just make sure it got enough time to startup:
        time.sleep(0.25)

    def tearDown(self):
        self._server.shutdown()
        self._thread.join()

    def test_base(self):
        _, data = ld.download_image('http://localhost:8080/x.png')
        self.assertEqual(data.strip(), b'dummy@/x.png')

        _, data = ld.download_image('http://localhost:8080/wait', timeout=1)
        self.assertEqual(data, None)

        _, data = ld.download_image('http://localhost:8080/404')
        self.assertEqual(data, None)

        _, data = ld.download_image('http://nosuchhost:8080/404')
        self.assertEqual(data, None)

        _, data = ld.download_image('http://ä is not a good url.')
        self.assertEqual(data, None)


if __name__ == '__main__':
    # There was an unclosed fd warning that was likely not my fault:
    unittest.main(warnings='ignore')
