{ lib, delib, ... }:
{
  splitStrPath = lib.splitString ".";

  getAttrByStrPath =
    strPath: attrset: default:
    lib.attrByPath (delib.splitStrPath strPath) default attrset;

  setAttrByStrPath = strPath: value: lib.setAttrByPath (delib.splitStrPath strPath) value;

  hasAttrs =
    attrs: attrset:
    if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;
}
