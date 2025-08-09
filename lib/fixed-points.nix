{
  delib,
  lib,
  ...
}:
{
  fix =
    f:
    let
      x = f x;
    in
    x;

  fixWithUnfix =
    f:
    let
      x = f x // {
        __unfix__ = f;
      };
    in
    x;

  recursivelyExtends =
    overlay: f:
    (
      final:
      let
        prev = f final;
      in
      lib.recursiveUpdate prev (overlay final prev)
    );

  recursivelyComposeExtensions =
    f: g: final: prev:
    let
      fApplied = f final prev;
      prev' = prev // fApplied;
    in
    lib.recursiveUpdate fApplied (g final prev');

  recursivelyComposeManyExtensions = lib.foldr (x: y: delib.recursivelyComposeExtensions x y) (
    final: prev: { }
  );

  makeRecursivelyExtensible = delib.makeRecursivelyExtensibleWithCustomName "recursivelyExtend";

  makeRecursivelyExtensibleWithCustomName =
    extenderName: rattrs:
    delib.fixWithUnfix (
      self:
      (
        (rattrs self)
        // {
          ${extenderName} =
            f: delib.makeRecursivelyExtensibleWithCustomName extenderName (delib.recursivelyExtends f rattrs);
        }
      )
    );
}
