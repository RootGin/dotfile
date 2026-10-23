{ self, ... }:
{
  flake.nixosModules.applicationsAiAgentSkills =
    { config, lib, pkgs, ... }:
    let
      inherit (config.userOptions) username;
      skillsCfg = config.programs.ai."agent-skills";

      # ── Sources ──
      uiUxProMaxSrc = pkgs.fetchFromGitHub {
        owner = "nextlevelbuilder";
        repo = "ui-ux-pro-max-skill";
        rev = "b7e3af80f6e331f6fb456667b82b12cade7c9d35";
        hash = "sha256-tgGnZt6ITH8IDPqglNDC1JCt5ZkVMGcET9IbP0vITjo=";
      };

      # Matt Pocock's "Skills For Real Engineers" (github.com/mattpocock/skills).
      # NOTE: pinned to the latest commit as of writing (2026-09-18).
      mattpocockSrc = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "c55ee46073ed923f86ce59a5eb3b6d895095d1b7";
        hash = "sha256-L3CpIT2DeI+fUFl9fcygojtQo2DzEen69rMD1XqR1vM=";
      };

      # ── Pre-built skill content ──
      rawUiUxProMaxSkill = builtins.readFile "${uiUxProMaxSrc}/.claude/skills/ui-ux-pro-max/SKILL.md";

      fixedUiUxProMaxSkill = builtins.replaceStrings [
        "python3 skills/ui-ux-pro-max/scripts/"
      ] [
        "python3 ~/.config/opencode/skills/ui-ux-pro-max/scripts/"
      ] rawUiUxProMaxSkill;

      # ── Matt Pocock skill lists (folder names under skills/<category>/) ──
      mattpocockEngineering = [
        "ask-matt"
        "grill-with-docs"
        "triage"
        "improve-codebase-architecture"
        "setup-matt-pocock-skills"
        "to-spec"
        "to-tickets"
        "implement"
        "wayfinder"
        "prototype"
        "diagnosing-bugs"
        "research"
        "tdd"
        "domain-modeling"
        "codebase-design"
        "code-review"
        "resolving-merge-conflicts"
        "wizard"
      ];

      mattpocockProductivity = [
        "grill-me"
        "handoff"
        "teach"
        "to-questionnaire"
        "wait-what"
        "grilling"
        "writing-for-agents"
      ];

      # ── Helpers ──
      mkMattPocockSkillFiles = category: names:
        builtins.listToAttrs (
          map (name: {
            name = "opencode/skills/${name}/SKILL.md";
            value.text = builtins.readFile "${mattpocockSrc}/skills/${category}/${name}/SKILL.md";
          }) names
        );
    in
    {
      options.programs.ai."agent-skills" = {
        enable = lib.mkEnableOption "Enable AI agent skills for OpenCode";

        "ui-ux-pro-max" = {
          enable = lib.mkEnableOption "Enable ui-ux-pro-max skill";
        };

        "mattpocock" = {
          enable = lib.mkEnableOption "Enable Matt Pocock's 'Skills For Real Engineers' (github:mattpocock/skills)";
          engineering = lib.mkEnableOption "Engineering skills (tdd, code-review, diagnosing-bugs, domain-modeling, wizard, etc.)";
          productivity = lib.mkEnableOption "Productivity skills (grill-me, handoff, teach, etc.)";
        };
      };

      config = lib.mkIf (config.programs.ai.enable && skillsCfg.enable) {
        home-manager.users.${username} = {
          # ── xdg.configFile → ~/.config/opencode/skills/ ──
          xdg.configFile =
            (lib.optionalAttrs skillsCfg."ui-ux-pro-max".enable {
              "opencode/skills/ui-ux-pro-max/SKILL.md".text = fixedUiUxProMaxSkill;
            })
            // (lib.optionalAttrs skillsCfg."ui-ux-pro-max".enable (
              builtins.listToAttrs (
                map (name: {
                  name = "opencode/skills/ui-ux-pro-max/scripts/${name}";
                  value.source = "${uiUxProMaxSrc}/.claude/skills/ui-ux-pro-max/scripts/${name}";
                }) [ "search.py" "core.py" "design_system.py" ]
              )
              // builtins.listToAttrs (
                map (name: {
                  name = "opencode/skills/ui-ux-pro-max/data/${name}";
                  value.source = "${uiUxProMaxSrc}/.claude/skills/ui-ux-pro-max/data/${name}";
                }) [
                  "_sync_all.py" "app-interface.csv" "charts.csv" "colors.csv"
                  "design.csv" "draft.csv" "google-fonts.csv" "icons.csv"
                  "landing.csv" "products.csv" "react-performance.csv" "styles.csv"
                  "typography.csv" "ui-reasoning.csv" "ux-guidelines.csv"
                ]
              )
              // builtins.listToAttrs (
                map (name: {
                  name = "opencode/skills/ui-ux-pro-max/data/stacks/${name}";
                  value.source = "${uiUxProMaxSrc}/.claude/skills/ui-ux-pro-max/data/stacks/${name}";
                }) [
                  "angular.csv" "astro.csv" "flutter.csv" "html-tailwind.csv"
                  "jetpack-compose.csv" "laravel.csv" "nextjs.csv" "nuxt-ui.csv"
                  "nuxtjs.csv" "react-native.csv" "react.csv" "shadcn.csv"
                  "svelte.csv" "swiftui.csv" "threejs.csv" "vue.csv"
                ]
              )
            ))
            // (lib.optionalAttrs skillsCfg."mattpocock".enable (
              (lib.optionalAttrs skillsCfg."mattpocock".engineering (
                mkMattPocockSkillFiles "engineering" mattpocockEngineering
              ))
              // (lib.optionalAttrs skillsCfg."mattpocock".productivity (
                mkMattPocockSkillFiles "productivity" mattpocockProductivity
              ))
            ));
        };
      };
    };
}
