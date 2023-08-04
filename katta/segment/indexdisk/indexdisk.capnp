using Go = import "/go.capnp";
@0xbffa186e7c6662d0;
$Go.package("indexdisk");
$Go.import("github.com/sahib/misc/katta/segment/indexdisk");

struct Entry {
    key @0 :Text;
    off @1 :Int64;
}
