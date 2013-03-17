---
layout: post
title: Optimal Meeting Point on the Paris Metro
---

tl;dr: Play with the app [here](/metro.html)

When you live in Paris, chances are you are (home or work) very close to a metro station, so when you want to meet with some friends, you usually end up picking another metro station as a meeting point. Yet, finding the optimal place to meet can easily become a complex problem considering the dense network we have. When I heard that the [RATP](http://www.ratp.fr) (the <check wikipedia for right wording> company) had made some of their datasets available, I thought this sounded like a good job to be solved with [R](http://www.r-project.org) and [Shiny](http://www.rstudio.org/shiny).

In the spirit of the current open data movement, the RATP has made available a number of datasets under <which license?>, and among them, two are of a particular interest for us:
- <find the name + link>, which gives us all the stops (metro, RER, buses, and tram, but we will stick with the metro here...), along with the lines that they are associated with, in the format <give format>
- <find the name + link>, which gives us the geographical positions of all stations, in the format <give format>
The following lines of code allows you to import and readily use the datasets:

{% highlight r %}
this
{% endhighlight %}

<see if some stats/charts are needed>

To state our problem more clearly, we are given initially a set of $n$ metro stops among all $N$ possible, and we want to find $S_opt$ the optimal stop where to meet. A first step will involve computing the distances among all metro stops (shortest path, preferably on a time scale rather than a space scale!), and the second step is to find some kind of "barycenter" of these $n$ stops. For these purposes, we model our metro network as a graph. The shortest path among two stops can be found using the very common [Dijkstra algorithm](<wikipedia link to dijkstra>), while defining the "barycenter" can be a bit cumbersome. Using a geographic barycenter doesn't make any sense (we might end up in a place with no stop, or even with the closest stop being physically far away from a duration perspective). The next thing could be to think of this problem as finding the centroid of the cluster formed by our $n$ stops, using something in the spirit of k-means (which doesn't need actual points in space but only distances), and mapping this centroid to our larger network, but empirically the results didn't look sound. No point in looking for midday at 2pm <find correct expression or wiki link>, another way to think of this is merely as a min-max problem: finding the stop which minimizes the maximum distance from each of the $n$ initial stops to $S_opt$. <any reference?> And this is actually very easy to implement in R!

There are two technical problems worth highlighting in my view:
- First, the RATP doesn't provide us with the dataset for the actual network, only a mapping from stations to lines. This means we don't know the actual ordering of the stations on the line, and this is actually not a simple $1:N$ mapping since we have forks and isolated circles (think of line 13 after "La Fourche", and line <7b??> where there is no terminus but a circle at the end of the line).
- Second, the RATP doesn't provide us with the dataset for the transportation time between any two stops, as this might be a great competitive advantage they have for gathering metro users to their website and app. I have no reference for this, I'm only guessing! 
The solutions used here for these two problems are as follow:
- We boldly assume that stop $A$ is connected to stops $B$ and $C$ if and only if stops $B$ and $C$ are the closest stops physically from $A$, $A$, $B$, $C$ are on the same line, and $B$ is different from $C$. That could work in a wonderful world. Here, this assumption is surprisingly not bad at all, but manual corrections are still needed (the worst line being <line X with stations xxx>, but otherwise no more than 1/2 errors per line).
- We boldly assume that the time taken from stop $A$ to stop $B$ can be decomposed into three parts:
* A stop time (train slows/accelerates, doors open/close, people get in/out), about 1 minute
* A connection time (only when changing lines), about <x> minutes
* The actual transportation time (physically between $A$ and $B$), proportional to the geographical distance from $A$ to $B$, about <x> minute per... minute. Since stops are referenced with longitude and latitude, the physical distance between the two is in minutes...
The calibration of the model has roughly been done manually with some trial and error, it is not perfect at all, but that does the job.

So here we are, equipped with our distance matrix $D$ between any two stops of the RATP metro network, ready to identify the optimal stop to meet when people come from, say, Barbès-Rochechouart, Bastille, Dupleix, and Pernety.

{% highlight r %}
this
{% endhighlight %}

Actually that was not a tricky one, considering how these four stops are so far from each other, but you just want to be sure someone is not <lésé>. Now consider this one:

That was less obvious... In case you have a similar problem one of these days, consider using [that page](/metro.html), where a [Shiny](http://www.rstudio.org/shiny) version of the app is available, along with a ggplot2 chart. I know this should be done in [D3](<find link>) for more interactivity, but that's on my todo for sure!

