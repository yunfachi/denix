{ delib, lib, ... }:
{
  toDenixArgs =
    function:
    if !delib.isDenixArgs function then
      if lib.isAttrs function then
        function
        // {
          _type = "denixAbstractionArgsFunctor";
        }
      else
        {
          _type = "denixAbstractionArgsFunctor";
          __functor = self: function;
          # __functionArgs = delib.functionArgs function;
        }
    else
      function;

  isDenixArgs = x: x._type or null == "denixAbstractionArgsFunctor";

  callIfDenixArgs = x: denixArgs: if delib.isDenixArgs x then x denixArgs else x;

  callWithMocksIfDenixArgs = x: if delib.isDenixArgs x then delib.callWithMocks x else x;
}
