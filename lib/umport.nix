# This function is copied from:
# https://github.com/yunfachi/nypkgs/blob/master/lib/umport.nix
#
# !!! REMOVING THIS NOTICE VIOLATES THE MIT LICENSE OF THE UMPORT PROJECT !!!
# This notice must be retained in all copies of this function, including modified versions!
# The MIT License can be found here:
# https://github.com/yunfachi/nypkgs/blob/master/LICENSE
{ lib, ... }:
{
  umport =
    {
      path ? null,
      paths ? [ ],
      include ? [ ],
      exclude ? [ ],
      recursive ? true,
    }:
    let
      recursively =
        let
          inherit (lib.fileset)
            unions
            union
            difference
            fileFilter
            toList
            ;
          nixOnly = paths: unions (map (fileFilter (file: file.hasExt "nix")) paths);

          pathsFs = nixOnly (paths ++ lib.optionals (path != null) [ path ]);
          includeFs = nixOnly include;
          excludeFs = nixOnly exclude;

          excluded = difference pathsFs excludeFs;
          included = union excluded includeFs;
        in
        toList included;

      nonRecursively =
        let
          isNotExcluded = path: lib.all (x: !lib.path.hasPrefix x path) exclude;
          readDirs = builtins.concatMap (
            path: map (x: path + "/${x}") (builtins.attrNames (builtins.readDir path))
          );

          pathsList = readDirs (paths ++ lib.optionals (path != null) [ path ]);
          includeList = readDirs include;

          excluded = lib.filter isNotExcluded pathsList;
          included = lib.unique (excluded ++ includeList);
          nixOnly = lib.filter (file: lib.pathIsDirectory file || lib.hasSuffix ".nix" file) included;
        in
        nixOnly;
    in
    if recursive then recursively else nonRecursively;
}
