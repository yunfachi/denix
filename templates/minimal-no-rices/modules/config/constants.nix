{delib, ...}:
delib.module {
  name = "constants";

  options.constants = with delib; {
    username = readOnly (strOption "sjohn");
    userfullname = readOnly (strOption "John Smith");
    useremail = readOnly (strOption "johnsmith@example.com");
  };
}
