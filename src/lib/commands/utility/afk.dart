import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx/nyxx.dart';
import 'package:hive/hive.dart';
import '../../utils/checkForGuild.dart';
import '../../handlers/registerInteractions.dart' show interactionsWS;

class AFKCommand {
  String name = "afk";
  String category = "utility";
  String description = "Set yourself as AFK in all servers.";
  bool dm_disabled = false;

  late final EmbedBuilder baseEmbed;
  late final IMessage message;

  execute(client) {
    print("[Command Ran] --> $name");

    final data = SlashCommandBuilder('$name', '$description', [
      CommandOptionBuilder(
        CommandOptionType.string,
        'reason',
        'Reason for AFK',
        required: true,
      )
    ])
      ..registerHandler((event) async {
        if (dm_disabled) checkForGuild(event);

        await event.acknowledge();

        final reason = (event.getArg('reason').value.toString());

        var box = await Hive.openBox('AFKs');
        var isAFK = box.get(event.interaction.userAuthor?.id.toString());

        if (isAFK == null) {
          await box.put('${event.interaction.userAuthor?.id.toString()}',
              {'active': true, 'reason': '${reason}'});

          print(
              '[AFK] AFK enabled for ${event.interaction.userAuthor?.username.toString()}.');

          baseEmbed = EmbedBuilder()
            ..addAuthor((author) {
              author.name = 'Aurora Bot';
            })
            ..title = 'AFK Enabled'
            ..description = 'You have marked yourself as AFK for `$reason`.'
            ..color = DiscordColor.fromHexString("#5865F2")
            ..timestamp = DateTime.now()
            ..addFooter((footer) {
              footer.text =
                  'Requested by ${event.interaction.userAuthor?.username}';
              footer.iconUrl = event.interaction.userAuthor?.avatarURL();
            });

          return event.respond(MessageBuilder.embed(baseEmbed));
        } else {
          var box = await Hive.openBox('AFKs');
          var isAFK = box.get(event.interaction.userAuthor?.id.toString());

          baseEmbed = EmbedBuilder()
            ..addAuthor((author) {
              author.name = 'Aurora Bot';
            })
            ..title = ':x: AFK Already Enabled'
            ..description =
                'You have already marked yourself as AFK for `${isAFK['reason']}`. To disable AFK, simply send a message in any channel.'
            ..color = DiscordColor.fromHexString("#5865F2")
            ..timestamp = DateTime.now()
            ..addFooter((footer) {
              footer.text =
                  'Requested by ${event.interaction.userAuthor?.username}';
              footer.iconUrl = event.interaction.userAuthor?.avatarURL();
            });

          return event.respond(MessageBuilder.embed(baseEmbed));
        }
      });
    interactionsWS..registerSlashCommand(data);
  }
}
