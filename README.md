# lita-reminder

# Work in progress - partially usable yet buggy

This is an effort to add an advanced task scheduler to lita bot. 
It is currenly in early development but partially usable as-is, but it might be
pretty buggy as of now.

Supports in, at, every and cron-like tasks. Uses Rufus-scheduler and Chronic.

Planned: domain expiration notification

## Installation

Add lita-reminder to your Lita instance's Gemfile:

``` ruby
gem "lita-reminder"
```

## Configuration

No configuration is currently present

## Usage

Schedule a task like this:

  remind here in 10m to do some stuff
  remind username in 10m to do some stuff repeat 10 times 5s
  remind me cron * * * * * to say "one minute passed"
  

## License

[MIT](http://opensource.org/licenses/MIT)
