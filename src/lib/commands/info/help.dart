import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "../../../config.dart";

class HelpCommand {
  String name = "help";
  String category = "info";
  String description = "The help command for this bot.";
  execute(client) {
    print("[Command Ran] --> $name");

    final data = SlashCommandBuilder("$name", "$description", [])
      ..registerHandler((event) async {
        final embed = EmbedBuilder()
          ..title = 'Dart Bot'
          ..description = 'Suck my nuts bozo'
          ..color = '#5865F2' as DiscordColor?;

        await event.respond(MessageBuilder.embed(embed));
      });

    if (CONFIG.register_on_ready) {
      registerSlashCommand(client, data);
    }
  }

  registerSlashCommand(client, data) {
    IInteractions.create(WebsocketInteractionBackend(client))
      ..registerSlashCommand(data)
      ..syncOnReady();
  }
}
