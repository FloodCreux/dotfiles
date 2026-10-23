set -l cmds up down dash status logs doctor start stop restart secrets secret upgrade install cli-sync setup open help
set -l secret_names r1rcm-vk setup-token vk-opencode vk-claude vk-codex vk-scripts

complete -c bifrost-gateway -f

complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a up -d 'Start or repair everything'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a down -d 'Stop the gateway'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a dash -d 'Copy setup token, open dashboard'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a status -d 'Running state and health'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a logs -d 'Gateway logs'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a doctor -d 'Check everything'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a start -d 'Start the launchd agent'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a stop -d 'Stop the launchd agent'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a restart -d 'Restart the gateway'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a secrets -d 'Manage keychain secrets'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a secret -d 'Print a keychain secret'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a upgrade -d 'Install, pin and restart a release'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a install -d 'Download a release'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a cli-sync -d 'Point the launcher at this gateway'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a setup -d 'Same as up'
complete -c bifrost-gateway -n "not __fish_seen_subcommand_from $cmds" -a help -d 'Show usage'

complete -c bifrost-gateway -n "__fish_seen_subcommand_from logs" -s f -d 'Follow'
complete -c bifrost-gateway -n "__fish_seen_subcommand_from doctor" -l fix -d 'Repair what it can'
complete -c bifrost-gateway -n "__fish_seen_subcommand_from doctor" -l quiet -d 'Only print problems'

complete -c bifrost-gateway -n "__fish_seen_subcommand_from secrets; and not __fish_seen_subcommand_from list set generate" -a 'list set' -d 'secrets action'
complete -c bifrost-gateway -n "__fish_seen_subcommand_from secrets; and not __fish_seen_subcommand_from list set" -l generate -d 'Create missing local secrets'
complete -c bifrost-gateway -n "__fish_seen_subcommand_from secret" -a "$secret_names"
complete -c bifrost-gateway -n "__fish_seen_subcommand_from secrets; and __fish_seen_subcommand_from set" -a "$secret_names"
