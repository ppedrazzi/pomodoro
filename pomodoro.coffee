###

v1
1. fix percentComplete helper on load.
2. Add 5 minute rest periods.
7. Store completed pomodoros.

LATER
4. Pull out pause for helper instead of resuing "start". (make discrete)
5. Set up for viewing on mobile.
6. Add sound for start and finished.
8. Enable different backdrops (rain, forest)
9. Enable different background noise & volume slider (coffeehouse, rain, chill)
10. Add Sharing buttons.


Bugs
1. Alert "x" does not close.
2. At end, return controls to "start Timer" state.
###


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
		Session.setDefault("intervalId", null)
		Session.setDefault("alert", null)
		Session.setDefault("paused", false)
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

	Template.timerControls.helpers
		interval: () ->
			if Session.get("intervalId") is null
				false
			else
				true
				
		paused: () ->
			if Session.get("paused") then true else false
							
	Template.alert.helpers
		alertHeader: () ->
			Session.get("alert")
			
		alertMessage: () ->
			"Congratulations!"
			
		finished: () ->
			Session.get("alert")
				
	Template.alert.events
		'click .close': () ->
			Session.set("alert", null)
			console.log "clicked alert close icon."
		
	Template.visualization.helpers
		timeRemaining: () ->
			moment(Session.get("timeRemaining")).format('mm:ss')

	Template.timer.helpers
		timerStartValue: () ->
			moment(Session.get("timerStartValue")).format('mm:ss')
			
		percentComplete: () ->
			if Session.get("intervalId") is null
				Session.get("percentComplete")
			else
				tLeft = Session.get("timeRemaining")
				tStart = Session.get("timerStartValue")
				totalStartingSeconds = ( (tStart.getMinutes() * 60) + (tStart.getSeconds()) )
				remainingSeconds = ( (tLeft.getMinutes() * 60) + (tLeft.getSeconds()) )
				amountComplete = (totalStartingSeconds - remainingSeconds) / totalStartingSeconds
				Session.set("amountRemaining", amountComplete.toFixed(2))
				Session.set("percentComplete", (amountComplete * 100).toFixed(0) )
				Session.get("percentComplete")
					

	Template.timer.events
		"click #start": () ->
			Session.set("alert", null)
			countDown = () ->
				t = Session.get("timeRemaining")
				if ( t.getMinutes() + t.getSeconds() ) > 0
					t1 = moment(t).subtract(1, 'seconds')
					t2 = moment(t1).toDate()
					Session.set("timeRemaining", t2)
				else
					Meteor.clearInterval(Session.get("intervalId"))
					Session.set("alert", "Nice Job - Take a Break!")
					
			if Session.get("intervalId") is null
				intervalId = Meteor.setInterval(countDown, 1000)
				Session.set("intervalId", intervalId)
				Session.set("paused", false)
				console.log "Start button clicked."
			else
				console.log "Start button ignored - timer is running."
			
		"click #pause": () ->
			if Session.get("intervalId") is null
				console.log "Clicked pause, but there is no interval."	
			else
				Meteor.clearInterval(Session.get("intervalId"))
				Session.set("intervalId", null)
				Session.set("paused", true)
				console.log "Pause button clicked."

		"click #cancel": () ->
			Meteor.clearInterval(Session.get("intervalId"))
			Session.set("intervalId", null)
			Session.set("timeRemaining", Session.get("timerStartValue"))
			Session.set("amountRemaining", 0)
			Session.set("percentComplete", 0)
			Session.set("alert", null)
			Session.set("paused", false)
			console.log "Cancel button clicked."


if Meteor.isServer
	Meteor.startup () ->
		console.log "Server is alive."
