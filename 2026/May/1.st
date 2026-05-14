"GitHub user info form for Squeak Smalltalk.

 How to run:
   1. Open a Workspace in Squeak.
   2. Paste this whole file.
   3. Select all and press Alt+D (Do it).
   A window opens; type a GitHub username, click Fetch, and the public
 profile fields are shown below."

| window userField output fetchButton fetch fieldFrom |

"Pulls a value for a top-level JSON key out of the raw response body.
 Crude but dependency-free so this works on a stock Squeak image without
 loading a JSON parser package."
fieldFrom := [:body :key | | needle i s e c result |
	needle := '"' , key , '":'.
	i := body indexOfSubCollection: needle.
	i = 0
		ifTrue: [result := '(none)']
		ifFalse: [
			s := i + needle size.
			[s <= body size and: [(body at: s) = Character space]]
				whileTrue: [s := s + 1].
			c := body at: s.
			c = $"
				ifTrue: [
					s := s + 1.
					e := s.
					[e <= body size and: [(body at: e) ~= $"]]
						whileTrue: [e := e + 1].
					result := s = e
						ifTrue: ['(none)']
						ifFalse: [body copyFrom: s to: e - 1]]
				ifFalse: [
					e := s.
					[e <= body size
						and: [(body at: e) ~= $,
						and: [(body at: e) ~= $}
						and: [(body at: e) ~= Character cr
						and: [(body at: e) ~= Character lf]]]]]
						whileTrue: [e := e + 1].
					result := (body copyFrom: s to: e - 1) withBlanksTrimmed.
					result = 'null' ifTrue: [result := '(none)']]].
	result].

fetch := [
	| username body stream |
	username := userField text asString withBlanksTrimmed.
	username isEmpty
		ifTrue: [output setText: 'Please type a GitHub username first.']
		ifFalse: [
			output setText: 'Fetching ' , username , ' ...'.
			World displayWorld.
			[
				body := (HTTPSocket httpGet: 'https://api.github.com/users/' , username) contents asString.
				(body includesSubstring: '"Not Found"')
					ifTrue: [output setText: 'User "' , username , '" was not found on GitHub.']
					ifFalse: [
						stream := WriteStream on: String new.
						stream
							nextPutAll: 'Login:        '; nextPutAll: (fieldFrom value: body value: 'login'); cr;
							nextPutAll: 'Name:         '; nextPutAll: (fieldFrom value: body value: 'name'); cr;
							nextPutAll: 'Bio:          '; nextPutAll: (fieldFrom value: body value: 'bio'); cr;
							nextPutAll: 'Company:      '; nextPutAll: (fieldFrom value: body value: 'company'); cr;
							nextPutAll: 'Location:     '; nextPutAll: (fieldFrom value: body value: 'location'); cr;
							nextPutAll: 'Blog:         '; nextPutAll: (fieldFrom value: body value: 'blog'); cr;
							nextPutAll: 'Public Repos: '; nextPutAll: (fieldFrom value: body value: 'public_repos'); cr;
							nextPutAll: 'Followers:    '; nextPutAll: (fieldFrom value: body value: 'followers'); cr;
							nextPutAll: 'Following:    '; nextPutAll: (fieldFrom value: body value: 'following'); cr;
							nextPutAll: 'Created:      '; nextPutAll: (fieldFrom value: body value: 'created_at'); cr;
							nextPutAll: 'Profile URL:  '; nextPutAll: 'https://github.com/' , (fieldFrom value: body value: 'login').
						output setText: stream contents]
			] on: Error do: [:ex | output setText: 'Error: ' , ex messageText]]].

window := SystemWindow labelled: 'GitHub User Info'.
window setWindowColor: (Color r: 0.93 g: 0.95 b: 1.0).

userField := PluggableTextMorph new.
userField setText: 'octocat'.
window addMorph: userField frame: (0.0 @ 0.0 corner: 0.75 @ 0.12).

fetchButton := SimpleButtonMorph new.
fetchButton label: 'Fetch'.
fetchButton target: fetch; actionSelector: #value.
window addMorph: fetchButton frame: (0.75 @ 0.0 corner: 1.0 @ 0.12).

output := PluggableTextMorph new.
output setText: 'Type a GitHub username above and click Fetch.'.
window addMorph: output frame: (0.0 @ 0.12 corner: 1.0 @ 1.0).

window openInWorld.
