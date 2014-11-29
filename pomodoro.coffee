if Meteor.isClient
	Meteor.startup () ->
		dur = 25
		time = new Date()
		time.setMinutes(dur)
		time.setSeconds(0)
		Session.setDefault("timerStartValue", time)
		Session.setDefault("timeRemaining", time)
		Session.setDefault("intervalId", 0)
		Session.setDefault("alert", "none")
		console.log "Client is Alive"
		
	Template.timer.helpers
		timeRemaining: () ->
			moment(Session.get("timeRemaining")).format('mm:ss')
			
		timerStartValue: () ->
			moment(Session.get("timerStartValue")).format('mm:ss')
			
		percentComplete: () ->
			if Session.get("intervalId") > 0
				#Base all on seconds.
				tLeft = Session.get("timeRemaining")
				tStart = Session.get("timerStartValue")
				totalStartingSeconds = ( (tStart.getMinutes() * 60) + (tStart.getSeconds()) )
				remainingSeconds = ( (tLeft.getMinutes() * 60) + (tLeft.getSeconds()) )
				percentComplete = (totalStartingSeconds - remainingSeconds) / totalStartingSeconds
				percentComplete.toFixed(2)
			else
				100
			
		alert: () ->
			Session.get("alert")

	Template.timer.events
		"click #start": () ->
			countDown = () ->
				t = Session.get("timeRemaining")
				if ( t.getMinutes() + t.getSeconds() ) > 0
					t1 = moment(t).subtract(1, 'seconds')
					t2 = moment(t1).toDate()
					Session.set("timeRemaining", t2)
				else
					Session.set("alert", "Nice Job - Take a Break!")
					
			if Session.get("intervalId") is 0
				intervalId = Meteor.setInterval(countDown, 1000)
				Session.set("intervalId", intervalId)
				console.log "Start button clicked."
			else
				console.log "Start button ignored - timer is running."
			
		"click #pause": () ->
			Meteor.clearInterval(Session.get("intervalId"))
			Session.set("intervalId", 0)
			console.log "Pause button clicked."

		"click #cancel": () ->
			Meteor.clearInterval(Session.get("intervalId"))
			Session.set("intervalId", 0)
			Session.set("timeRemaining", Session.get("timerStartValue"))
			console.log "Cancel button clicked."


if Meteor.isServer
	Meteor.startup () ->
		console.log "Server is alive."
