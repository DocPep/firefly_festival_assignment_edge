# Firefly Festival – Elixir Assignment

How to run:
1) This is not a module-heavy code as explained below, hence just a few steps as follows after cloning this repo:
cd firefly_festival
mix run

Some Notes as follows:
1) Made a single module (No idea how project structures in Elixir work as of now, found online that mix is the thing I should use and created a project using that and a single file module.)
2) The 50 processes spawn was confusing, when the rest of the assignment mentioned 10, hence I made an assumption to have it as 10. It is still configurable so may not be an issue.
3) Made the fireflies communicate only with its right fly, instead of broadcasting the message. Since only significant action happens on receiving the blink signal from our left neighbour, and rest fireflies are ignored.
4) LLM usage was done to understand the syntax of the language, get examples on various constructs, and understanding what exactly happens in a statement (The docs got started using too tech-heavy words sometimes).

Explanation:

Here I'll explain in brief what I have done in the assignment.

So the assignment basically asked us to spawn processes (fireflies), and have them communicate with each other so that they can blink in sync.
How I approached it was trying to make it as simple as possible, since I'm not very familiar with Elixir and its capabilities.
