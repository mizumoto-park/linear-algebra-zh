// settexpreamble.asy  Set up a common texpreamble
// Use in your final mygraphic.asy as:
//   cd("../../../asy/");
//   import settexpreamble;
//   cd("");
//   settexpreamble();

string settexpreamble() {
  // Get the current directory
  string current_dir = cd("");
  // Find the src/ directory: asy is always run from somewhere under src/,
  // for instance src/jc/asy or src/asy.  This works no matter what the
  // parent directory is named (linear-algebra, linear-algebra-src, etc).
  int src_dex = rfind(current_dir, "/src");
  string src_dir = substr(current_dir, 0, src_dex) + "/src";
  texpreamble("\usepackage{"+src_dir+"/sty/conc}\usepackage{"+src_dir+"/sty/linalgjh}");
  return(src_dir);
}
