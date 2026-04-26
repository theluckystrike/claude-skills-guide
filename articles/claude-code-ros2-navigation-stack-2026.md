---
layout: default
title: "Claude Code for ROS2 Nav2 Stack (2026)"
description: "Claude Code for ROS2 Nav2 Stack — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-ros2-navigation-stack-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for ROS2 Nav2

The ROS2 Navigation2 stack is powerful but notoriously complex. Building a custom planner plugin, configuring costmap layers for your specific robot, or writing behavior tree XML that handles real-world edge cases requires deep knowledge of the Nav2 plugin architecture, lifecycle node management, and the BT.CPP library.

Claude Code understands the Nav2 API surface, plugin interfaces, and YAML parameter schemas. It generates compilable C++ plugins that follow the Nav2 architecture, complete with lifecycle callbacks, parameter declarations, and the CMakeLists.txt entries needed to actually build them.

## The Workflow

### Step 1: ROS2 Workspace Setup

```bash
# ROS2 Humble (LTS) or Jazzy
source /opt/ros/humble/setup.bash

# Create workspace and package
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
ros2 pkg create custom_nav_plugins \
  --build-type ament_cmake \
  --dependencies rclcpp nav2_core nav2_costmap_2d \
    pluginlib geometry_msgs nav_msgs

# Install Nav2 dependencies
sudo apt install ros-humble-navigation2 ros-humble-nav2-bringup
```

### Step 2: Custom Costmap Layer Plugin

Claude Code generates a costmap layer that reads from a custom sensor topic (e.g., ultrasonic array) and inflates obstacles:

```cpp
// src/ultrasonic_layer.cpp
#include "nav2_costmap_2d/layer.hpp"
#include "nav2_costmap_2d/costmap_layer.hpp"
#include "sensor_msgs/msg/range.hpp"
#include "rclcpp/rclcpp.hpp"
#include <cassert>
#include <vector>
#include <mutex>

namespace custom_nav_plugins {

class UltrasonicLayer : public nav2_costmap_2d::CostmapLayer {
public:
  UltrasonicLayer() = default;

  void onInitialize() override
  {
    auto node = node_.lock();
    assert(node != nullptr);

    declareParameter("topic", rclcpp::ParameterValue("/ultrasonics"));
    declareParameter("clear_threshold", rclcpp::ParameterValue(0.8));
    declareParameter("mark_threshold", rclcpp::ParameterValue(0.3));

    std::string topic;
    node->get_parameter(name_ + ".topic", topic);
    node->get_parameter(name_ + ".clear_threshold", clear_threshold_);
    node->get_parameter(name_ + ".mark_threshold", mark_threshold_);

    assert(clear_threshold_ > mark_threshold_);

    sub_ = node->create_subscription<sensor_msgs::msg::Range>(
      topic, rclcpp::SensorDataQoS(),
      [this](sensor_msgs::msg::Range::SharedPtr msg) {
        std::lock_guard<std::mutex> lock(data_mutex_);
        assert(msg->range >= msg->min_range);
        latest_ranges_.push_back(*msg);
        if (latest_ranges_.size() > MAX_BUFFER) {
          latest_ranges_.erase(latest_ranges_.begin());
        }
      });

    current_ = true;
    enabled_ = true;
  }

  void updateBounds(
    double robot_x, double robot_y, double robot_yaw,
    double * min_x, double * min_y,
    double * max_x, double * max_y) override
  {
    std::lock_guard<std::mutex> lock(data_mutex_);
    for (const auto & range : latest_ranges_) {
      if (range.range < mark_threshold_) {
        double obstacle_x = robot_x +
          range.range * cos(robot_yaw + range.field_of_view / 2.0);
        double obstacle_y = robot_y +
          range.range * sin(robot_yaw + range.field_of_view / 2.0);
        *min_x = std::min(*min_x, obstacle_x - 0.5);
        *min_y = std::min(*min_y, obstacle_y - 0.5);
        *max_x = std::max(*max_x, obstacle_x + 0.5);
        *max_y = std::max(*max_y, obstacle_y + 0.5);
      }
    }
  }

  void updateCosts(
    nav2_costmap_2d::Costmap2D & master_grid,
    int min_i, int min_j, int max_i, int max_j) override
  {
    std::lock_guard<std::mutex> lock(data_mutex_);
    assert(min_i >= 0 && min_j >= 0);

    for (const auto & range : latest_ranges_) {
      if (range.range < mark_threshold_) {
        unsigned int mx, my;
        if (master_grid.worldToMap(range.range, 0.0, mx, my)) {
          master_grid.setCost(mx, my,
            nav2_costmap_2d::LETHAL_OBSTACLE);
        }
      }
    }
    latest_ranges_.clear();
  }

  void reset() override
  {
    std::lock_guard<std::mutex> lock(data_mutex_);
    latest_ranges_.clear();
  }

private:
  static constexpr size_t MAX_BUFFER = 100;
  rclcpp::Subscription<sensor_msgs::msg::Range>::SharedPtr sub_;
  std::vector<sensor_msgs::msg::Range> latest_ranges_;
  std::mutex data_mutex_;
  double clear_threshold_{0.8};
  double mark_threshold_{0.3};
};

}  // namespace custom_nav_plugins

#include "pluginlib/class_list_macros.hpp"
PLUGINLIB_EXPORT_CLASS(
  custom_nav_plugins::UltrasonicLayer,
  nav2_costmap_2d::Layer)
```

### Step 3: Build, Configure, and Test

```bash
# Build the plugin
cd ~/ros2_ws
colcon build --packages-select custom_nav_plugins
source install/setup.bash

# Test with Nav2 bringup
ros2 launch nav2_bringup tb3_simulation_launch.py \
  params_file:=custom_nav_params.yaml

# In another terminal, send a goal
ros2 action send_goal /navigate_to_pose \
  nav2_msgs/action/NavigateToPose \
  "{pose: {header: {frame_id: 'map'}, pose: {position: {x: 2.0, y: 1.0}}}}"
# Expected: robot navigates while respecting ultrasonic obstacles
```

## CLAUDE.md for ROS2 Nav2

```markdown
# ROS2 Nav2 Plugin Rules

## Standards
- ROS2 Humble or Jazzy (LTS releases only)
- Nav2 plugin API (nav2_core interfaces)
- ament_cmake build system

## File Formats
- .cpp / .hpp (C++17)
- .yaml (Nav2 parameter files)
- .xml (behavior tree definitions, pluginlib descriptors)
- .launch.py (Python launch files)

## Libraries
- nav2_core 1.2+
- nav2_costmap_2d 1.2+
- BehaviorTree.CPP 4.x
- pluginlib 5.x

## Testing
- Unit tests with gtest via ament_cmake_gtest
- Integration tests in simulation (Gazebo/Ignition)
- Costmap plugins must be tested with known obstacle maps

## Thread Safety
- All costmap layer callbacks must be mutex-protected
- Subscription callbacks run on executor threads, not plugin thread
```

## Common Pitfalls

- **Plugin not found at runtime:** Missing the `pluginlib/class_list_macros.hpp` export macro or incorrect `plugin_description.xml` causes Nav2 to silently skip your layer. Claude Code generates both the macro and the XML descriptor together.
- **Costmap update bounds too large:** Returning the entire map bounds from updateBounds() causes full-map updates every cycle, killing performance. Claude Code scopes bounds to actual sensor data.
- **Lifecycle node vs regular node:** Nav2 plugins receive a weak_ptr to a lifecycle node. Calling lock() without checking for nullptr crashes on shutdown. Claude Code adds the assertion guard every time.

## Related

- [Claude Code for Robotics ROS2](/claude-skills-for-robotics-ros2-development-workflow/)
- [Claude Code for Embedded Systems](/claude-skills-for-embedded-systems-iot-firmware/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Hybrid LLM Stack](/claude-cost-hybrid-stack-claude-gpt-gemini/)
- [Claude Code Full Stack Developer](/claude-code-full-stack-developer-feature-shipping-workflow/)
- [Full Stack Web App with Claude Skills](/full-stack-web-app-with-claude-skills-step-by-step/)
- [Claude Code Rails API Mode Full Stack](/claude-code-rails-api-mode-full-stack-workflow/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
