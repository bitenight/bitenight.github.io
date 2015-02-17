---
---


class Visualizer

	constructor: (filePath, @bars_amount) ->

		@audio = new Audio()
		@audio.src = filePath

		@audio.loop = true
		@audio.autoplay = true
		#document.getElementById('audio_box').appendChild(@audio)

		@canvas = document.getElementById('analyser_render')
		@context = new AudioContext()


	initPlayer: () =>



		@analyser = @context.createAnalyser()

		@ctx = @canvas.getContext('2d')

		@source = @context.createMediaElementSource(@audio)
		@source.connect(@analyser)
		@analyser.connect(@context.destination)

		this.loop()


	loop: () =>



		window.requestAnimationFrame(this.loop)
		@fbc_array = new Uint8Array(@analyser.frequencyBinCount)
		@analyser.getByteFrequencyData(@fbc_array)

		@ctx.clearRect(0, 0, @canvas.width, @canvas.height)
		@ctx.fillStyle = '#2c43d7'


		bars = [1..@bars_amount]



		for bar, idx in bars
			this.createBars(idx)



	createBars: (i) =>
		bar_x = i * 3;
		bar_width = 2;
		bar_height = -(@fbc_array[i] / 2)

		@ctx.fillRect(bar_x, @canvas.height, bar_width, bar_height)




app = angular.module 'siteApp', ['ngAnimate', 'ngResource']


app.config [ '$interpolateProvider', ($interpolateProvider) ->

	$interpolateProvider.startSymbol('{[{').endSymbol('}]}')

	SC.initialize({
  	client_id: '64d890ff67b7796c0b7f927d15ef7037'
	})



]


app.factory 'Songs', ['$resource', ($resource) ->

  $resource('http://api.soundcloud.com/users/:id/tracks', {id: '@id'},

    query: {method: 'GET', params: {client_id: '64d890ff67b7796c0b7f927d15ef7037'}, isArray: true},
    update: { method: 'PUT'}

  )

]


app.controller 'OffCanvasController', [ ->
	this.isActive = false


	this.toggle = () =>
		console.log 'toggled'
		this.isActive = !this.isActive


	this.open = () =>
		thi.isActive = true

	this.close = () =>
		thi.isActive = false
]




app.controller 'HeroController', [ ->

	visualizer = new Visualizer('/sounds/recit.mp3', 150)

	visualizer.initPlayer()

]


app.controller 'MusicController', [ '$scope', 'Songs', ($scope, Songs) ->

	#$scope.visualizer = new Visualizer('/sounds/recit.mp3', 100)

	#$scope.visualizer.initPlayer()

	#console.log $scope.visualizer

	$scope.songs = []

	$scope.current_song = null

	$scope.playing = false

	$scope.resource = Songs.query({id: 79743396}, (result) =>

		$scope.songs = result

		console.log result

	)



	$scope.play = (song) ->

		$scope.playing = !$scope.playing

		$scope.current_song.destruct() if $scope.current_song

		SC.stream(song.stream_url, (song) ->
			$scope.current_song = song
			$scope.current_song.play()
		)

		return false
]
