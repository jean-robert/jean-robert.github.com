---
layout: post
title: Cluster your Facebook friends
---

Last week, I came across two interesting posts by Romain François and Petr Simecek:

* [Crawling Facebook with R](http://romainfrancois.blog.free.fr/index.php?post/2012/01/15/Crawling-facebook-with-R), in which Romain explains how to connect to the Facebook Graph API
* [Mining Facebook Data: Most "Liked" Status and Friendship Network](http://applyr.blogspot.com/2012/01/mining-facebook-data-most-liked-status.html), in which Petr use Romain's function to visualize your friend's network.

As coincidence would have it, I also came across an older introductory post about social network analysis ([Grey’s Anatomy Network of Sexual Relations](http://www.babelgraph.org/wp/?p=1)) which could actually complement quite well the two posts above.

Using the [igraph](http://cran.r-project.org/web/packages/igraph/index.html) package, it is very easy to use the [Girvan-Newman algorithm](http://en.wikipedia.org/wiki/Girvan%E2%80%93Newman_algorithm) to automatically detect your clusters of friends.

![friendscluster](/resources/friendscluster.png)

Here is the full code to create the chart above:

<script src="https://gist.github.com/1657558.js?file=friendscluster.R"></script>


