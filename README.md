## Alternode: Node Meta Manipulation

### Description:

A [Minetest](http://minetest.net/) mod that allows administrators with *server* privilege to examine & alter node meta data. Additionally, a pencil tool is provided with limited use for players to alter *infotext* meta value.

### Usage:

**Chat commands:**

- */getmeta <x> <y> <z> <key>*
  - prints the value of `key` in meta data of node at `x,y,z`.
- */setmeta <x> <y> <z> <key> <new_value>*
  - Sets the value of `key` in meta data of node at `x,y,z`.
- */unsetmeta <x> <y> <z> <key>*
  - Unsets the value of `key` in meta data of node at `x,y,z`.

**Info stick:**

Invoke `/giveme alternode:infostick`. Use the infostick on a node to receive node coordinates, name, & some select meta info.

**Pencil:**

The `alternode:pencil` is a tool for players to set/unset the `infotext` meta value of nodes within protected/owned areas.

### Licensing:

- Code: [MIT](LICENSE.txt)
- Textures: CC0
  - `alternode_infostick.png & alternode_pencil.png:` by AntumDeluge
  - `alternode_wand.png:` by [rcorre](https://opengameart.org/node/40598)

### Links:

- [Forum](https://forum.minetest.net/viewtopic.php?t=26667)
- [Git repo](http://github.com/AntumMT/mod-alternode)
- [Changelog](CHANGES.txt)
- [TODO](TODO.txt)
