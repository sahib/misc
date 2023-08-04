using Go = import "/go.capnp";
@0x85d3acc39d94e0f9;
$Go.package("waldisk");
$Go.import("github.com/sahib/misc/katta/wal/waldisk");

struct Entry {
    key @0 :Text;
    val @1 :Data;
}
