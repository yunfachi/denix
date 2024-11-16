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
  inherit (lib.types) anything attrsOf bool coercedTo enum float int listOf number package path port singleLineStr str submodule;
  attrs = attrsOf anything;
  attrsLegacy = lib.types.attrs;
  lambda = lib.types.functionTo anything;
  lambdaTo = lib.types.functionTo;
  list = listOf anything;

  anythingOption = simpleOption anything;
  attrsLegacyOption = simpleOption attrsLegacy;
  attrsOfOption = simpleOptionWithParameter attrsOf;
  attrsOption = simpleOption attrs;
  boolOption = simpleOption bool;
  coercedToOption = coercedType: coerceFunc: finalType: simpleOption (coercedTo coercedType coerceFunc finalType);
  enumOption = simpleOptionWithParameter enum;
  floatOption = simpleOption float;
  intOption = simpleOption int;
  lambdaOption = simpleOption lambda;
  lambdaToOption = simpleOptionWithParameter lambdaTo;
  listOfOption = simpleOptionWithParameter listOf;
  listOption = simpleOption list;
  numberOption = simpleOption number;
  packageOption = simpleOption package;
  pathOption = simpleOption path;
  portOption = simpleOption port;
  singleLineStrOption = simpleOption singleLineStr;
  strOption = simpleOption str;
  submoduleOption = simpleOptionWithParameter submodule;

  allowAnything = addTypeToOption anything;
  allowAttrs = addTypeToOption attrs;
  allowAttrsLegacy = addTypeToOption attrsLegacy;
  allowAttrsOf = addTypeWithParameterToOption attrsOf;
  allowBool = addTypeToOption bool;
  allowCoercedToOption = coercedType: coerceFunc: finalType: addTypeToOption (coercedTo coercedType coerceFunc finalType);
  allowEnum = addTypeWithParameterToOption enum;
  allowFloat = addTypeToOption float;
  allowInt = addTypeToOption int;
  allowLambda = addTypeToOption lambda;
  allowLambdaTo = addTypeWithParameterToOption lambdaTo;
  allowList = addTypeToOption list;
  allowListOf = addTypeWithParameterToOption listOf;
  allowNull = option: option // {type = lib.types.nullOr option.type;};
  allowNumber = addTypeToOption number;
  allowPackage = addTypeToOption package;
  allowPath = addTypeToOption path;
  allowPortOption = addTypeToOption port;
  allowSingleLineStrOption = addTypeToOption singleLineStr;
  allowStr = addTypeToOption str;

  noDefault = option: builtins.removeAttrs option ["default"];
  readOnly = option: option // {readOnly = true;};

  apply = option: apply: option // {inherit apply;};
  description = option: description: option // {inherit description;};

  singleEnableOption = default: {name, ...}:
    attrset.setAttrByStrPath "${name}.enable" (boolOption default);
}
