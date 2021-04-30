## Node Manipulation

### Description:

Mod that allows administrators with *server* privilege to examine & alter node meta data.

### Licensing:

- [MIT](LICENSE.txt)

### Usage:

Invoke `/giveme alternode:infostick`. Use the infostick on a node to recieve coordinate & other information.

**Chat commands:**

- */getmeta <x> <y> <z> <key>*
  - prints the value of `key` in the node's meta data at `x,y,z`.
- */setmeta <x> <y> <z> string|int|float <key> <new_value>*
  - Sets the value of `key` in the meta data of node at `x,y,z`.
