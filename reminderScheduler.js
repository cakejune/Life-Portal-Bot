const schedule = require("node-schedule"); // npm install node-schedule
const reminders = new Map();

function parseTimeDuration(duration) {
    const now = new Date();
    const match = duration.match(/^(\d+)([hmsd])$/);
    if (match) {
        const value = parseInt(match[1], 10);
        const unit = match[2];
        switch (unit) {
            case 'h': // hours
                now.setHours(now.getHours() + value);
                break;
            case 'm': // minutes
                now.setMinutes(now.getMinutes() + value);
                break;
            case 's': // seconds
                now.setSeconds(now.getSeconds() + value);
                break;
            case 'd': // days
                now.setDate(now.getDate() + value);
                break;
        }
        return now;
    }
    throw new Error("Invalid time duration format");
}

function scheduleReminder({ time, message, channelId, client }) {
    try {
        const reminderTime = parseTimeDuration(time);
        const job = schedule.scheduleJob(reminderTime, function () {
            const channel = client.channels.cache.get(channelId);
            if (channel) {
                channel.send(`Reminder: ${message}`);
            }
        });
        // Optionally, store the job if you need to cancel it later
        return job;
    } catch (error) {
        console.error("Failed to parse the time duration:", error);
    }
}


// This would be a more complex function if you are using a database or persistent storage
function checkReminders(client) {
  // Pseudocode: Iterate over all reminders
  // For each reminder:
  // Check if the current time is past the reminder time
  // If it is, send the reminder and cancel/delete it from the schedule
  console.log("Checking for due reminders...");
  // Example: Retrieving reminders from a stored location
  const reminders = getRemindersFromStorage();
  const now = new Date();
  reminders.forEach(reminder => {
      if (now >= new Date(reminder.time)) { // Assuming 'reminder.time' is stored as an ISO string
          const channel = client.channels.cache.get(reminder.channelId);
          if (channel) {
              channel.send(`Reminder: ${reminder.message}`);
              // Remove or mark as sent, depending on your storage method
              removeReminderFromStorage(reminder);
          }
      }
  });
}

module.exports = { scheduleReminder };
