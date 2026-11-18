{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  nodejs_24,
}:

stdenv.mkDerivation rec {
  pname = "rea-agents";
  version = "6.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    hash = "sha256-MiM4oVBeJVdwKhYBLn1Gq9tXKWQdmJOGYnYt+/t5Jio=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  # rea-agents 6.9.0 emits `"pattern": "^[^\\uD800-\\uDFFF]*$"` in JSON Schema
  # (fixed upstream in morluto/rea main via rejectUnpairedSurrogates), which
  # DeepSeek/RE2/Rust regex validators reject. Switch to .refine() so runtime
  # validation is preserved without advertising the non-portable regex pattern.
  postPatch = ''
    for f in dist/domain/localPath.js dist/cli-runtime/jsonValue-*.js dist/mcp/jsonValue-*.js; do
      substituteInPlace "$f" \
        --replace-fail '.regex(/^[^\uD800-\uDFFF]*$/u,' '.refine((v) => !/[\uD800-\uDFFF]/u.test(v),'
    done
    ${nodejs_24}/bin/node -e '
      const fs = require("fs");
      const crypto = require("crypto");
      const glob = (dir, prefix) => fs.readdirSync(dir).filter(f => f.startsWith(prefix)).map(f => dir + "/" + f);

      const strip = (v) => {
        if (Array.isArray(v)) v.forEach(strip);
        else if (v && typeof v === "object") {
          if (v.pattern === "^[^\\uD800-\\uDFFF]*$") delete v.pattern;
          for (const k of Object.keys(v)) strip(v[k]);
        }
      };

      const sha256 = (s) => crypto.createHash("sha256").update(s).digest("hex");

      import("./node_modules/canonicalize/lib/canonicalize.js").then(({ default: canonicalize }) => {
        const replacements = [];
        for (const [p, profile] of [
          ["dist/mcp-catalog.json", "compact"],
          ["dist/mcp-catalog-full.json", "full"],
        ]) {
          const data = JSON.parse(fs.readFileSync(p, "utf8"));
          strip(data);
          const oldTools = data.identity.digests.tools_sha256;
          const oldCombined = data.identity.digests.combined_sha256;

          const toolsCanon = canonicalize({ output_schema_profile: profile, catalog: data.tools });
          const newTools = sha256(toolsCanon);

          // Recompute combined using the existing prompts & cli list if needed, or check createServer
          data.identity.digests.tools_sha256 = newTools;
          const outBytes = Buffer.from(JSON.stringify(data));
          const oldFileHash = profile === "compact"
            ? "0deabecf50b32d04f65b11dacd8c43bc59012c0e64bbb997d5cc7738f5774056"
            : "7a42465aa77d17f158eb5c5211aa7ab560568a0775d067ae7c167ee9d57e12f4";
          const newFileHash = sha256(outBytes);
          fs.writeFileSync(p, outBytes);
          replacements.push([oldTools, newTools], [oldFileHash, newFileHash]);
        }

        const targets = [
          "dist/recordedCatalogDigests.js",
          "dist/recordedMcpCatalog.js",
          "dist/mcp/main.js",
          ...glob("dist/cli-runtime", "catalogIdentity-"),
          ...glob("dist/mcp", "createServer-"),
        ];
        for (const t of targets) {
          let txt = fs.readFileSync(t, "utf8");
          for (const [oldH, newH] of replacements) {
            txt = txt.split(oldH).join(newH);
          }
          fs.writeFileSync(t, txt);
        }
      });
    '
  '';

  installPhase = ''
    runHook preInstall

    local pkgDir="$out/lib/node_modules/rea-agents"
    mkdir -p "$pkgDir" "$out/bin"
    cp -r . "$pkgDir"

    # Remove foreign platform prebuilt .node binaries so autoPatchelfHook only inspects linux-x64
    rm -rf "$pkgDir"/node_modules/@lydell/node-pty-win32-* \
           "$pkgDir"/node_modules/@lydell/node-pty-darwin-* \
           "$pkgDir"/node_modules/@lydell/node-pty-linux-arm64 \
           "$pkgDir"/native/windows

    for binName in rea rea-agents; do
      makeWrapper ${nodejs_24}/bin/node "$out/bin/$binName" \
        --add-flags "$pkgDir/scripts/rea.mjs"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Reverse engineer anything from your terminal or agent with one CLI and MCP server";
    homepage = "https://github.com/morluto/rea";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rea";
  };
}
