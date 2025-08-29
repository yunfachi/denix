{ lib, delib, ... }:
{
  splitStrPath = lib.splitString ".";

  getAttrByStrPath =
    strPath: attrset: default:
    lib.attrByPath (delib.attrset.splitStrPath strPath) default attrset;

  setAttrByStrPath = strPath: value: lib.setAttrByPath (delib.attrset.splitStrPath strPath) value;

  hasAttrs =
    attrs: attrset:
    if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;
}
