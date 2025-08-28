{ lib, ... }:
let
  splitStrPath = lib.splitString ".";
in
{
  getAttrByStrPath =
    strPath: attrset: default:
    lib.attrByPath (splitStrPath strPath) default attrset;

  setAttrByStrPath = strPath: value: lib.setAttrByPath (splitStrPath strPath) value;

  hasAttrs =
    attrs: attrset:
    if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;
}
