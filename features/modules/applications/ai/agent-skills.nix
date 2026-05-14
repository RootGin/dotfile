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

      anthropicsSkillsSrc = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "skills";
        rev = "d211d437443a7b2496a3dad9575e7dddd724c585";
        hash = "sha256-5NGI0gojBGoXXus8CPhIrigyWSEYJg8gnCzWYl6PsLA=";
      };

      eccSrc = pkgs.fetchFromGitHub {
        owner = "affaan-m";
        repo = "everything-claude-code";
        rev = "58489af64f760dc05d63964c49e7bdd8c0ead0c1";
        hash = "sha256-vfhD+aGiyMxrYkPaK3WIa2CTlrdTuiABF0L6isXXg7U=";
      };

      ocxSrc = pkgs.fetchFromGitHub {
        owner = "kdcokenny";
        repo = "ocx";
        rev = "9fe679010df21235fe76a255b925f0077c5431c2";
        hash = "sha256-hSAABf9XB37ZAHszIkynpEG76Nr0R6XFVY6MxOQLoqs=";
      };

      # ── Pre-built skill content ──
      rawFrontendDesignSkill = builtins.readFile "${anthropicsSkillsSrc}/skills/frontend-design/SKILL.md";

      rawUiUxProMaxSkill = builtins.readFile "${uiUxProMaxSrc}/.claude/skills/ui-ux-pro-max/SKILL.md";

      fixedUiUxProMaxSkill = builtins.replaceStrings [
        "python3 skills/ui-ux-pro-max/scripts/"
      ] [
        "python3 ~/.config/opencode/skills/ui-ux-pro-max/scripts/"
      ] rawUiUxProMaxSkill;

      # ── ECC skill lists ──
      eccJava      = [ "java-coding-standards" "springboot-patterns" "jpa-patterns" ];
      eccJs        = [ "backend-patterns" "api-design" "error-handling" "api-connector-builder" "nestjs-patterns" "bun-runtime" "coding-standards" ];
      eccDotnet    = [ "dotnet-patterns" ];
      eccDevops    = [ "docker-patterns" "deployment-patterns" "security-review" ];
      eccFrontend  = [ "frontend-patterns" "nextjs-turbopack" "accessibility" "browser-qa" ];
      eccGeneral   = [ "architecture-decision-records" "git-workflow" "codebase-onboarding" "production-audit" ];

      # ── OCX skills ──
      ocxSkills = [
        "code-philosophy" "code-review" "frontend-philosophy" "plan-protocol" "plan-review"
      ];

      # ── Helpers ──
      mkEccSkillFiles = names:
        builtins.listToAttrs (
          map (name: {
            name = ".agents/skills/${name}/SKILL.md";
            value.text = builtins.readFile "${eccSrc}/skills/${name}/SKILL.md";
          }) names
        );

      mkOcxSkillFiles = names:
        builtins.listToAttrs (
          map (name: {
            name = ".agents/skills/${name}/SKILL.md";
            value.text = builtins.readFile "${ocxSrc}/workers/kdco-registry/files/skills/${name}/SKILL.md";
          }) names
        );
    in
    {
      options.programs.ai."agent-skills" = {
        enable = lib.mkEnableOption "Enable AI agent skills for OpenCode";

        "frontend-design" = {
          enable = lib.mkEnableOption "Enable frontend-design skill from anthropics/skills";
        };

        "ui-ux-pro-max" = {
          enable = lib.mkEnableOption "Enable ui-ux-pro-max skill";
        };

        "everything-claude-code" = {
          enable = lib.mkEnableOption "Enable curated skills from everything-claude-code";
          java      = lib.mkEnableOption "Java/Spring Boot skills";
          javascript = lib.mkEnableOption "JavaScript/Node.js skills";
          dotnet    = lib.mkEnableOption "C#/.NET skills";
          devops    = lib.mkEnableOption "DevOps skills (Docker, deployment, security)";
          frontend  = lib.mkEnableOption "Frontend skills (complementary)";
          general   = lib.mkEnableOption "General development skills";
        };

        "ocx-skills" = {
          enable = lib.mkEnableOption "Enable OCX skills (code-philosophy, code-review, plan-protocol, etc.)";
        };
      };

      config = lib.mkIf (config.programs.ai.enable && skillsCfg.enable) {
        home-manager.users.${username} = {
          # ── xdg.configFile → ~/.config/opencode/skills/ ──
          xdg.configFile =
            (lib.optionalAttrs skillsCfg."frontend-design".enable {
              "opencode/skills/frontend-design/SKILL.md".text = rawFrontendDesignSkill;
            })
            // (lib.optionalAttrs skillsCfg."ui-ux-pro-max".enable {
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
            ));

          # ── home.file → ~/.agents/skills/ ──
          home.file =
            (lib.optionalAttrs skillsCfg."everything-claude-code".enable (
              (lib.optionalAttrs skillsCfg."everything-claude-code".java      (mkEccSkillFiles eccJava))
              // (lib.optionalAttrs skillsCfg."everything-claude-code".javascript (mkEccSkillFiles eccJs))
              // (lib.optionalAttrs skillsCfg."everything-claude-code".dotnet    (mkEccSkillFiles eccDotnet))
              // (lib.optionalAttrs skillsCfg."everything-claude-code".devops    (mkEccSkillFiles eccDevops))
              // (lib.optionalAttrs skillsCfg."everything-claude-code".frontend  (mkEccSkillFiles eccFrontend))
              // (lib.optionalAttrs skillsCfg."everything-claude-code".general   (mkEccSkillFiles eccGeneral))
            ))
            // (lib.optionalAttrs skillsCfg."ocx-skills".enable (mkOcxSkillFiles ocxSkills));
        };
      };
    };
}
