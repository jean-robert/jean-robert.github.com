---
layout: default
title: All Posts
---


# All Posts #

<ul class="post-list">
{% for post in site.posts %}
  <li><a href="{{ post.url }}">{{ post.title }}</a> <span class="date">( {{ post.date | date: "%b %Y" }} )</span></li>
{% endfor %}     
</ul>

