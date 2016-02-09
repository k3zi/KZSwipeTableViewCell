Pod::Spec.new do |spec|
    spec.name = "KZSwipeTableViewCell"

    spec.version = "1.0.0"
    spec.summary = "Convenient UITableViewCell subclass that implements a swippable content to trigger actions (Swift Port of MCSwipeTableViewCell)"
    spec.homepage = "https://github.com/k3zi/KZSwipeTableViewCell"
    spec.license = { type: 'MIT', file: 'LICENSE' }
    spec.authors = { "Kesi Maduka" => 'me@kez.io' }
    spec.social_media_url = "https://twitter.com/k3zi_"

    spec.platform = :ios, "9.0"
    spec.requires_arc = true
    spec.source = { git: "https://github.com/k3zi/KZSwipeTableViewCell.git", tag: spec.version, submodules: false }
    spec.source_files = "KZSwipeTableViewCell/*.{swift}"
end
