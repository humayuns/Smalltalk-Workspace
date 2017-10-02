"Hello world!"
Transcript clear.
Transcript show:'Hello, World!'.

"random quotes"
quotes := #('The best way to predict the future is to invent it.' 
				'Perspective is worth 80 IQ points.'
				'People who are really serious about software should make their own hardware.'
				).

quote := (quotes at: (quotes size) atRandom).
Transcript clear.
Transcript show: quote