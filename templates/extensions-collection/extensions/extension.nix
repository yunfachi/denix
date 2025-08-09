{
  lib,
  delib,
  ...
}:
delib.extension {
  name = "awesomeExtension";
  description = "...";

  config = final: prev: {
    path = "sequence";
    fun1 = n: n / 2;
    fun2 = n: 3 * n + 1;
  };

  libExtension = config: final: prev: {
    genSequence =
      n:
      if n <= 0 then
        [ ]
      else if n == 1 then
        [ 1 ]
      else
        [ n ] ++ final.genSequence (config."fun${toString (n - n / 2 * 2 + 1)}" n);
  };

  modules = config: [
    (
      { delib, ... }:
      delib.module {
        name = config.path;

        options =
          with delib;
          setAttrByStrPath config.path {
            first100Sequences = listOption (lib.genList delib.genSequence 100);
          };
      }
    )
  ];
}
