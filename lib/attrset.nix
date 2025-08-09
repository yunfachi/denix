{ lib, ... }:
{
  getAttrByStrPath =
    strPath: attrset: default:
    lib.attrByPath (lib.splitString "." strPath) default attrset;

  setAttrByStrPath = strPath: value: lib.setAttrByPath (lib.splitString "." strPath) value;

  hasAttrs =
    attrs: attrset:
    if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;
}
