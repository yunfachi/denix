{lib, ...}: {
  getAttrByStrPath = strPath: attrset: default:
    lib.attrByPath (lib.splitString "." strPath) default attrset;

  setAttrByStrPath = strPath: value:
    lib.setAttrByPath (lib.splitString "." strPath) value;
}
