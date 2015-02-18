---
---


class MusicPlayer

	constructor: (@bars_amount, @visuals = false) ->

		@isPlaying = false

		@client_id = '64d890ff67b7796c0b7f927d15ef7037'

		@audio = new Audio()


		#@audio.loop = true
		#@audio.autoplay = true
		#document.getElementById('audio_box').appendChild(@audio)

		@canvas = document.getElementById('analyser_render')
		@context = new AudioContext()


		@analyser = @context.createAnalyser()

		@ctx = @canvas.getContext('2d')

		@source = @context.createMediaElementSource(@audio)
		@source.connect(@analyser)
		@analyser.connect(@context.destination)


		console.log @source.mediaElement



	play: (source) =>

		this.stop() if @isPlaying

		@audio.src = source.stream_url + '?client_id=' + @client_id

		@source.mediaElement.play()

		@isPlaying = true

		this.loop() if @visuals



	stop: () =>

		return if not @isPlaying

		@source.mediaElement.pause()

		@audio.src = ''

		@isPlaying = false


	loop: () =>



		window.requestAnimationFrame(this.loop)
		@fbc_array = new Uint8Array(@analyser.frequencyBinCount)
		@analyser.getByteFrequencyData(@fbc_array)

		@ctx.clearRect(0, 0, @canvas.width, @canvas.height)
		@ctx.fillStyle = '#bbb'


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




app.controller 'HeroController', [ '$scope', 'Songs', ($scope, Songs) ->

	$scope.resource = Songs.query({id: 79743396}, (result) =>

		$scope.song = result[0]

		console.log $scope.song

		#$scope.visualizer = new Visualizer($scope.song.stream_url, 150)
	)



	$scope.play = () ->

		$scope.visualizer.play()


	$scope.stop = () ->

		$scope.visualizer.stop()





]


app.controller 'MusicController', [ '$scope', 'Songs', ($scope, Songs) ->

	$scope.player = new MusicPlayer(100, true)

	$scope.songs = []


	$scope.current = null


	$scope.resource = Songs.query({id: 79743396}, (result) =>

		$scope.songs = result

		#console.log result

	)



	$scope.play = (song) =>

		$scope.stop($scope.current) if $scope.current

		$scope.current = song

		$scope.player.play(song)

		song.playing = true

		return false


	$scope.stop = (song) =>

		song.playing = false

		$scope.player.stop()



		return false
]
