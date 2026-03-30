{ lib, ... }:
{
  getAttrByStrPath =
    set: strPath: default:
    lib.attrByPath (lib.splitString "." strPath) default set;

  setAttrByStrPath =
    value: strPath:
    if strPath != null then lib.setAttrByPath (lib.splitString "." strPath) value else value;

  hasAttrs =
    set: attrs: if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr set) attrs else true;

  removeAttrs = removeAttrs;

  keepAttrs =
    attrs: names:
    removeAttrs attrs (builtins.filter (name: !builtins.elem name names) (builtins.attrNames attrs));

  strictMergeAttrs =
    left: right:
    let
      conflicts = builtins.attrNames (builtins.intersectAttrs left right);
    in
    if conflicts != [ ] then
      throw "strictMergeAttrs: conflicting keys: ${builtins.concatStringsSep ", " conflicts}"
    else
      left // right;
}
