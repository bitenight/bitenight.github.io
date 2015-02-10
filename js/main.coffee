---
---

app = angular.module 'siteApp', ['ngAnimate']



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
