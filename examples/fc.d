import fontconfig.fontconfig;
import std.stdio, std.string, std.conv : to;

int main() {
  FcPattern* pattern = FcPatternCreate();

  FcPatternAddString(pattern, FC_FAMILY, toStringz("DejaVu Serif"));
  FcPatternAddInteger(pattern, FC_WEIGHT, FC_WEIGHT_NORMAL);
  FcPatternAddInteger(pattern, FC_SLANT, FC_SLANT_ITALIC);

  FcConfigSubstitute(null, pattern, FcMatchKind.Pattern);
  FcDefaultSubstitute(pattern);

  FcChar8* post_config_family;
  FcPatternGetString(pattern, FC_FAMILY, 0, &post_config_family);

  writeln("post-config-family ", to!string(post_config_family));

  FcResult result;
  FcPattern* match = FcFontMatch(null, pattern, &result);
  if (!match) {
    FcPatternDestroy(pattern);
    return 1;
  }

  FcChar8* post_match_family;
  FcPatternGetString(match, FC_FAMILY, 0, &post_match_family);

  writeln("post-match-family ", to!string(post_match_family));

  FcChar8* filename;
  if (FcPatternGetString(match, FC_FILE, 0, &filename) != FcResult.Match) {
    FcPatternDestroy(match);
    return 1;
  }

  writeln("filename ", to!string(filename));
  FcPatternDestroy(match);

  return 0;
}
