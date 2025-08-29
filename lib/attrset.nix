{ lib, ... }:
{
  getAttrByStrPath =
    set: strPath: default:
    lib.attrByPath (lib.splitString "." strPath) default set;

  setAttrByStrPath = value: strPath: lib.setAttrByPath (lib.splitString "." strPath) value;

  hasAttrs =
    set: attrs: if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr set) attrs else true;
}
