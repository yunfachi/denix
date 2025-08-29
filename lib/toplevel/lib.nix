{ lib, ... }:
let
  fixedPoints = import ./fixed-points.nix { inherit lib; };
in
{
  /**
    Creates a recursively extensible library with additional `_callLib` and `_callLibArgs`.

    # Inputs

    `libName`

    : 1\. The attribute name that will represent the "self" of the library in the arguments of library parts called via `_callLib`

    `ext`

    : 2\. The initial extension for the library. It is transformed using `toExtensionWithFinalFirst`

    # Type

    ```
    mkLib :: string -> ((attrset -> attrset -> attrset) | (attrset -> attrset) | attrset) -> attrset
    ```

    # Example

    ```nix
    customLib = mkLib "customLib" (customLib: prev: {
      # No need to do `_callLibArgs = prev.callLibArgs // { foo = "foo"; };`,
      # because mkLib uses recursive updating of attrsets.
      _callLibArgs.foo = "foo";

      function = x: x + 1
      antiFunction = x: customLib.function x - 1
    })
    ```
  */
  mkLib =
    libName: ext:
    let
      extensible = fixedPoints.makeRecursivelyExtensible (self: {

        /**
          Arguments passed to library parts called via `_callLib`.

          # Type

          ```
          attrset
          ```

          # Example

          ```nix
          customLib = mkLib "customLib" {}

          customLib = customLib.recursivelyExtend (
            final: prev: {
              _callLibArgs = {
                denixNamePrefix = "de";
              };

              inherit
                (final._callLib (
                  { denixNamePrefix, ... }: { denixName = "${denixNamePrefix}nix"; }
                ))
                denixName;
            }
          )

          customLib.denixNamePrefix
          => error: attribute 'denixNamePrefix' missing

          customLib.denixName
          => "denix"

          customLib._callLibArgs
          =>
          {
            customLib = { ... };
            denixNamePrefix = "de";
            lib = { ... };
          }
          ```
        */
        _callLibArgs = {
          inherit lib;
          ${libName} = self;
        };

        /**
          Сall a library part `target` using `_callLibArgs`.

          The `target` may be:

          * a `path` - import it, then if it's a function call it with `_callLibArgs`;
          * a function - call it with `_callLibArgs`;
          * otherwise - returned unchanged.

          # Inputs

          `target`

          : 1\. Path, function, or anything else

          # Type

          ```
          _callLib :: (path | (attrset -> any) | any) -> any
          ```

          # Example

          ```nix
          # ./mylib.nix => args: { greeting = "hi"; }

          _callLib ./mylib.nix
          => { greeting = "hi"; }

          _callLib ({ ... }: { greeting = "hi"; })
          => { greeting = "hi"; }

          _callLib { greeting = "hi"; }
          => { greeting = "hi"; }

          _callLib "hi"
          => "hi"
          ```
        */
        _callLib =
          target:
          let
            maybeFunction = if builtins.isPath target then import target else target;
            callable = if lib.isFunction maybeFunction then maybeFunction else _: maybeFunction;
          in
          callable self._callLibArgs;
      });
    in
    extensible.recursivelyExtend (fixedPoints.toExtensionWithFinalFirst ext);
}
