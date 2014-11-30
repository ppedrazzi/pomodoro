if Meteor.isClient
	Meteor.startup () ->
		dur = 25
		time = new Date()
		time.setMinutes(dur)
		time.setSeconds(0)
		Session.setDefault("timerStartValue", time)
		Session.setDefault("timeRemaining", time)
		Session.setDefault("amountRemaining", 0)
		Session.setDefault("percentComplete", 0)
		Session.setDefault("intervalId", 0)
		Session.setDefault("alert", "none")
		console.log "Client is Alive"
	
	Tracker.autorun( () ->
		$(".circle").circleProgress
			value: (1 - Session.get("amountRemaining"))
			animation: false
			startAngle: 0
			size: 200
			fill:
				gradient: [
					"#ff1e41"
					"#ff5f43"])


	Template.visualization.helpers
		timeRemaining: () ->
			moment(Session.get("timeRemaining")).format('mm:ss')
			
		percentComplete: () ->
			Session.get("percentComplete")
		
	Template.timer.helpers
		timerStartValue: () ->
			moment(Session.get("timerStartValue")).format('mm:ss')
			
		percentComplete: () ->
			if Session.get("intervalId") > 0
				#Base all on seconds.
				tLeft = Session.get("timeRemaining")
				tStart = Session.get("timerStartValue")
				totalStartingSeconds = ( (tStart.getMinutes() * 60) + (tStart.getSeconds()) )
				remainingSeconds = ( (tLeft.getMinutes() * 60) + (tLeft.getSeconds()) )
				amountComplete = (totalStartingSeconds - remainingSeconds) / totalStartingSeconds
				Session.set("amountRemaining", amountComplete.toFixed(2))
				Session.set("percentComplete", (amountComplete * 100).toFixed(0) )
				Session.get("percentComplete")
			else
				Session.get("percentComplete")
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
					Meteor.clearInterval(Session.get("intervalId"))
					Session.set("alert", "Nice Job - Take a Break!")
					
			if Session.get("intervalId") is 0
				intervalId = Meteor.setInterval(countDown, 1000)
				Session.set("intervalId", intervalId)
				console.log "Start button clicked."
			else
				console.log "Start button ignored - timer is running."
			
		"click #pause": () ->
			if Session.get("intervalId") > 0
				Meteor.clearInterval(Session.get("intervalId"))
				Session.set("intervalId", 0)
				console.log "Pause button clicked."
			else
				console.log "Clicked pause, but there is no interval."	

		"click #cancel": () ->
			Meteor.clearInterval(Session.get("intervalId"))
			Session.set("intervalId", 0)
			Session.set("timeRemaining", Session.get("timerStartValue"))
			Session.set("amountRemaining", 0)
			Session.set("percentComplete", 0)
			console.log "Cancel button clicked."


if Meteor.isServer
	Meteor.startup () ->
		console.log "Server is alive."
