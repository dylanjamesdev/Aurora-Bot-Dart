import 'package:http/http.dart' as http;
import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import '../../handlers/registerInteractions.dart';

class PingCommand {
  String name = "ping";
  String category = "info";
  String description = "Get the websocket latency of the bot.";
  execute(client) {
    print("[Command Ran] --> $name");

    final data = SlashCommandBuilder("$name", "$description", [])
      ..registerHandler((event) async {
        await event.acknowledge();

        final gatewayDelayInMillis = (event.client as INyxxWebsocket)
                .shardManager
                .shards
                .map((e) => e.gatewayLatency.inMilliseconds)
                .reduce((value, element) => value + element) /
            (event.client as INyxxWebsocket).shards;
        final gatewayLatency = gatewayDelayInMillis.abs().floor();

        final apiStopwatch = Stopwatch()..start();
        await http.head(Uri(
            scheme: 'https', host: Constants.host, path: Constants.baseUri));
        final apiLatency = apiStopwatch.elapsedMilliseconds;
        apiStopwatch.stop();

        final latencyEmbed = EmbedBuilder()
          ..addAuthor((author) {
            author.name = 'Unnamed Bot';
          })
          ..color = DiscordColor.fromHexString("#5865F2")
          ..title = ':ping_pong: Ping'
          ..timestamp = DateTime.now()
          ..addField(
              name: 'Gateway latency',
              content: '$gatewayLatency ms',
              inline: false)
          ..addField(
              name: 'REST latency', content: '$apiLatency ms', inline: false)
          ..addField(
              name: 'Message latency', content: 'Pending ...', inline: false)
          ..addFooter((footer) {
            footer.text =
                'Requested by: ${event.interaction.userAuthor?.username}';
            footer.iconUrl = event.interaction.userAuthor?.avatarURL();
          });

        final messageStopwatch = Stopwatch()..start();
        final message =
            await event.sendFollowup(MessageBuilder.embed(latencyEmbed));

        latencyEmbed.replaceField(
          name: 'Message latency',
          content: '${messageStopwatch.elapsedMilliseconds} ms',
          inline: false,
        );

        await message.edit(MessageBuilder.embed(latencyEmbed));
        messageStopwatch.stop();
      });

    interactionsWS..registerSlashCommand(data);
  }
}
