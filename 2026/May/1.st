"GitHub user info form for Squeak Smalltalk.

 How to run:
   1. Open a Workspace in Squeak.
   2. Paste this whole file.
   3. Select all and press Alt+D (Do it).
 A window opens; type a GitHub username, click Fetch, and the public
 profile fields are shown below."

| window userField output fetchButton extractField doFetch trim |

"Manual whitespace trim — avoids depending on #trimSeparators or
 #withBlanksTrimmed, since different Squeak versions ship different names."
trim := [:str |
	| i j |
	i := 1.
	j := str size.
	[i <= j and: [(str at: i) isSeparator]] whileTrue: [i := i + 1].
	[j >= i and: [(str at: j) isSeparator]] whileTrue: [j := j - 1].
	str copyFrom: i to: j].

"--- 1. Build the UI first so userField/output are bound before any block
       that references them is compiled. This avoids the
       'userField appears to be undefined at this point' warning. ---"

window := SystemWindow labelled: 'GitHub User Info'.
window setWindowColor: (Color r: 0.93 g: 0.95 b: 1.0).

userField := PluggableTextMorph new.
userField setText: 'octocat'.
window addMorph: userField frame: (0.0 @ 0.0 corner: 0.75 @ 0.12).

output := PluggableTextMorph new.
output setText: 'Type a GitHub username above and click Fetch.'.
window addMorph: output frame: (0.0 @ 0.12 corner: 1.0 @ 1.0).

"--- 2. Tiny JSON field extractor. Pulls a top-level string or number value
       for a given key from the raw response body. Dependency-free so the
       script runs on a stock Squeak image. ---"

extractField := [:body :key |
	| needle terminators i s e c result |
	terminators := String new: 4.
	terminators at: 1 put: (Character value: 44).   "comma"
	terminators at: 2 put: (Character value: 125).  "close-brace"
	terminators at: 3 put: Character cr.
	terminators at: 4 put: Character lf.

	needle := '"' , key , '":'.
	i := body indexOfSubCollection: needle.
	result := '(none)'.
	i > 0 ifTrue: [
		s := i + needle size.
		[s <= body size and: [(body at: s) = Character space]]
			whileTrue: [s := s + 1].
		s <= body size ifTrue: [
			c := body at: s.
			c = $"
				ifTrue: [
					s := s + 1.
					e := s.
					[e <= body size and: [(body at: e) ~= $"]]
						whileTrue: [e := e + 1].
					s < e ifTrue: [result := body copyFrom: s to: e - 1]]
				ifFalse: [
					e := s.
					[e <= body size and: [(terminators includes: (body at: e)) not]]
						whileTrue: [e := e + 1].
					result := trim value: (body copyFrom: s to: e - 1) asString.
					(result isEmpty or: [result = 'null']) ifTrue: [result := '(none)']]]].
	result].

"--- 3. Fetch action. ---"

doFetch := [
	| username body s |
	username := trim value: userField text asString.
	username isEmpty
		ifTrue: [output setText: 'Please type a GitHub username first.']
		ifFalse: [
			output setText: 'Fetching ' , username , ' ...'.
			World displayWorld.
			[
				body := (HTTPSocket httpGet: 'https://api.github.com/users/' , username) contents asString.
				(body indexOfSubCollection: '"Not Found"') > 0
					ifTrue: [output setText: 'User "' , username , '" was not found on GitHub.']
					ifFalse: [
						s := WriteStream on: String new.
						s nextPutAll: 'Login:        '; nextPutAll: (extractField value: body value: 'login'); cr.
						s nextPutAll: 'Name:         '; nextPutAll: (extractField value: body value: 'name'); cr.
						s nextPutAll: 'Bio:          '; nextPutAll: (extractField value: body value: 'bio'); cr.
						s nextPutAll: 'Company:      '; nextPutAll: (extractField value: body value: 'company'); cr.
						s nextPutAll: 'Location:     '; nextPutAll: (extractField value: body value: 'location'); cr.
						s nextPutAll: 'Blog:         '; nextPutAll: (extractField value: body value: 'blog'); cr.
						s nextPutAll: 'Public Repos: '; nextPutAll: (extractField value: body value: 'public_repos'); cr.
						s nextPutAll: 'Followers:    '; nextPutAll: (extractField value: body value: 'followers'); cr.
						s nextPutAll: 'Following:    '; nextPutAll: (extractField value: body value: 'following'); cr.
						s nextPutAll: 'Created:      '; nextPutAll: (extractField value: body value: 'created_at'); cr.
						s nextPutAll: 'Profile URL:  https://github.com/' , (extractField value: body value: 'login').
						output setText: s contents]
			] on: Error do: [:ex | output setText: 'Error: ' , ex messageText]]].

"--- 4. Wire the button to doFetch and show the window. ---"

fetchButton := SimpleButtonMorph new.
fetchButton label: 'Fetch'.
fetchButton target: doFetch; actionSelector: #value.
window addMorph: fetchButton frame: (0.75 @ 0.0 corner: 1.0 @ 0.12).

window openInWorld.
