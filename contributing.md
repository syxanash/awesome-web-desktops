# Contribution Guidelines

* The website suggested must have a design which look like a typical desktop computer GUI, ideally something like [this](https://en.wikipedia.org/wiki/Graphical_user_interface#Examples).
* Please add your link to the **bottom** of the list as I'd like to keep a chronological order for the additions.
* Please do not add websites that are hidden behind logins (without available credentials), or paywalls.
* Please add only fully developed websites or apps that are in working condition. Projects that are in an early stage or broken will not be accepted.
* Search previous suggestions before making a new one, as yours may be a duplicate.
* Make an individual pull request for each suggestion.
* New categories, or improvements to the existing categorization are welcome.
* Check your spelling and grammar.

## Adding a new website to the list

In order to add a new site to the list you can simply add a new row to the main table in `README.md`.
The **first column** contains name and link to the website, the **second column** instead will specify if the site/project source code is available. There are no restrictions on the license on which the source code is released as long as it's been published somewhere.

A **full row** would look like this:

```
[WEBSITE_NAME](https://WEBSITE_URL) | [![open](assets/open.png) available](https://REPOSITORY_URL) |
```

whereas if the source code is **not** available:

```
[WEBSITE_NAME](https://WEBSITE_URL) | ![locked](assets/locked.png) private |
```

If you have any additional information relevant to booting your web desktop, such as login credentials or specific browser requirements, please add them to the third column 'User notes'.

```
[WEBSITE_NAME](https://WEBSITE_URL) | ![locked](assets/locked.png) private | login: admin / password

or

[WEBSITE_NAME](https://WEBSITE_URL) | ![locked](assets/locked.png) private | only works in Chrome
```

Thank you for contributing!
