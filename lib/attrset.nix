{ lib, ... }:
let
  splitStrPath = lib.splitString ".";
  splitPath = s: if s != null then splitStrPath s else [ ];
in
{
  mkModuleArgs =
    {
      name, # string: user-defined name of the module
      category ? null, # string: optional prefix for the name above
      myconfig, # attrs: base attrset
    }:
    let
      cfgPath = (splitPath category) ++ (splitStrPath name);

      fromPath = with lib; path: if (length path) > 0 then attrByPath path { } myconfig else myconfig;

      cfg = fromPath cfgPath;
      parent = fromPath (lib.dropEnd 1 cfgPath);
    in
    {
      inherit
        name
        myconfig
        cfg
        parent
        ;
    };

  getAttrByStrPath =
    strPath: attrset: default:
    lib.attrByPath (splitStrPath strPath) default attrset;

  setAttrByStrPath = strPath: value: lib.setAttrByPath (splitStrPath strPath) value;

  hasAttrs =
    attrs: attrset:
    if attrs != [ ] then builtins.any (attr: builtins.hasAttr attr attrset) attrs else true;
}
