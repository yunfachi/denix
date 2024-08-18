{
  lib,
  attrset,
  ...
}: let
  mkOption = default: types:
    lib.mkOption {
      type = lib.types.oneOf (lib.toList types);
      inherit default;
    };

  addTypeToOption = type: option:
    option // {type = lib.types.oneOf [option.type type];};
  addTypeWithParameterToOption = type: elemType: option:
    addTypeToOption (type elemType) option;

  simpleOption = type: default:
    mkOption default type;
  simpleOptionWithParameter = type: elemType: default:
    simpleOption (type elemType) default;
in rec {
  inherit (lib.types) anything attrs attrsOf bool enum float int listOf number path str submodule;
  lambda = lib.types.functionTo anything;
  lambdaTo = lib.types.functionTo;
  list = listOf anything;

  anythingOption = simpleOption anything;
  attrsOfOption = simpleOptionWithParameter attrsOf;
  attrsOption = simpleOption attrs;
  boolOption = simpleOption bool;
  enumOption = simpleOptionWithParameter enum;
  floatOption = simpleOption float;
  intOption = simpleOption int;
  lambdaOption = simpleOption lambda;
  lambdaToOption = simpleOptionWithParameter lambdaTo;
  listOfOption = simpleOptionWithParameter listOf;
  listOption = simpleOption list;
  numberOption = simpleOption number;
  pathOption = simpleOption path;
  strOption = simpleOption str;
  submoduleOption = simpleOptionWithParameter submodule;

  allowAnything = addTypeToOption anything;
  allowAttrs = addTypeToOption attrs;
  allowAttrsOf = addTypeWithParameterToOption attrsOf;
  allowBool = addTypeToOption bool;
  allowEnum = addTypeWithParameterToOption enum;
  allowFloat = addTypeToOption float;
  allowInt = addTypeToOption int;
  allowLambda = addTypeToOption lambda;
  allowLambdaTo = addTypeWithParameterToOption lambdaTo;
  allowList = addTypeToOption list;
  allowListOf = addTypeWithParameterToOption listOf;
  allowNull = option: option // {type = lib.types.nullOr option.type;};
  allowNumber = addTypeToOption number;
  allowPath = addTypeToOption path;
  allowStr = addTypeToOption str;

  readOnly = option: option // {readOnly = true;};
  noDefault = option: builtins.removeAttrs option ["default"];

  description = option: description: option // {inherit description;};

  singleEnableOption = default: {name, ...}:
    attrset.setAttrByStrPath "${name}.enable" (boolOption default);
}