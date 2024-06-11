const {
  Client,
  GatewayIntentBits,
  Events,
  EmbedBuilder,
  Partials,
} = require("discord.js");
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent, 
    GatewayIntentBits.GuildMessageReactions, 
  ],
  partials: [Partials.Message, Partials.Channel, Partials.Reaction], 
});
const prefix = "~";
const todoChannelId = "1242223222129168384"; 
const doneChannelId = "1243436089444929626"; 

client.once(Events.ClientReady, () => {
  console.log("Bot is online!");
});

client.on(Events.MessageReactionAdd, async (reaction, user) => {
  handleReaction(reaction, user);
});

client.on(Events.MessageCreate, (message) => {
  processCommand(message);
});

const commands = {
  ping: (message) => message.channel.send("Pong!"),
  hello: (message) => message.channel.send("Hello, world!"),
  schedule: (message, args) => {
    const time = args[0];
    message.channel.send(`Scheduled event at ${time}`);
  },
  table: (message) => handleTable(message),
  woof: (message) => message.channel.send("Woof!"),
  // Add more commands here
};

function processCommand(message) {
  if (!message.content.startsWith(prefix) || message.author.bot) return;

  const args = message.content.slice(prefix.length).trim().split(/ +/);
  const commandName = args.shift().toLowerCase();

  const command = commands[commandName];
  if (command) {
    command(message, args);
  } else {
    message.channel.send("Unknown command");
  }
}

async function handleReaction(reaction, user) {
    if (reaction.partial) {
      
        try {
            await reaction.fetch();
        } catch (error) {
            console.error('Something went wrong when fetching the reaction:', error);
            return;
        }
    }

    if (reaction.message.partial) {
      
        try {
            await reaction.message.fetch();
        } catch (error) {
            console.error('Something went wrong when fetching the message:', error);
            return;
        }
    }

    if (reaction.message.channelId === todoChannelId && !user.bot) {
        const targetChannel = await client.channels.fetch(doneChannelId);
        if (targetChannel) {
            const now = new Date();
            const timestamp = now.toISOString().replace(/T/, ' ').replace(/\..+/, '');  // Format to YYYY-MM-DD HH:mm:ss
            
            targetChannel.send(`Completed task: ${reaction.message.content} on ${timestamp}.`);
            await reaction.message.delete();
        }
    }
}

function handleTable(message) {
  const embed = new EmbedBuilder()
    .setColor("#0099ff")
    .setTitle("Table of String Functions")
    .addFields(
      {
        name: "Function",
        value: "LOWER(), LCASE()\nUPPER(), UCASE()...",
        inline: true,
      },
      {
        name: "Description",
        value: "Return string in lowercase\nReturn string in uppercase...",
        inline: true,
      }
    );
  message.channel.send({ embeds: [embed] });
}

client.login(process.env.DISCORD_BOT_EARTH_PLANS_TOKEN);
