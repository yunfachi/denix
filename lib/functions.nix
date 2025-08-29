{ delib, lib, ... }:
{
  functionArgs =
    f:
    if f ? __functionArgs then
      f.__functionArgs
    else if f ? __functor then
      delib.functionArgs (f.__functor f)
    else
      builtins.functionArgs f;

  setFunctionArgs =
    f: args:
    if lib.isAttrs f then
      f
      // {
        __functionArgs = args;
      }
    else
      {
        __functor = self: f;
        __functionArgs = args;
      };

  mirrorFunctionArgs =
    f:
    let
      fArgs = delib.functionArgs f;
    in
    g: delib.setFunctionArgs g fArgs;

  # TODO: https://github.com/NixOS/nixpkgs/pull/453578
  inheritFunctionArgs =
    f: g:
    let
      fArgs = delib.functionArgs f;
      gArgs = delib.functionArgs g;
    in
    delib.setFunctionArgs g (fArgs // gArgs);

  callWithMocks = f: f (delib.functionArgs f);
}
