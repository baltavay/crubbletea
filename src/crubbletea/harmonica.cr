require "math"

module Crubbletea::Harmonica
  EPSILON = 2.220446049250313e-16

  def self.fps(n : Int32) : Float64
    1.0 / n.to_f64
  end

  struct Point
    getter x : Float64
    getter y : Float64
    getter z : Float64

    def initialize(@x = 0.0, @y = 0.0, @z = 0.0)
    end
  end

  struct Vector
    getter x : Float64
    getter y : Float64
    getter z : Float64

    def initialize(@x = 0.0, @y = 0.0, @z = 0.0)
    end
  end

  GRAVITY          = Vector.new(0.0, -9.81, 0.0)
  TERMINAL_GRAVITY = Vector.new(0.0, 9.81, 0.0)

  struct Spring
    @pos_pos_coef : Float64
    @pos_vel_coef : Float64
    @vel_pos_coef : Float64
    @vel_vel_coef : Float64

    def initialize(delta_time : Float64, angular_frequency : Float64, damping_ratio : Float64)
      angular_frequency = {angular_frequency, 0.0}.max
      damping_ratio = {damping_ratio, 0.0}.max

      if angular_frequency < EPSILON
        @pos_pos_coef = 1.0
        @pos_vel_coef = 0.0
        @vel_pos_coef = 0.0
        @vel_vel_coef = 1.0
      elsif damping_ratio > 1.0 + EPSILON
        za = -angular_frequency * damping_ratio
        zb = angular_frequency * Math.sqrt(damping_ratio * damping_ratio - 1.0)
        z1 = za - zb
        z2 = za + zb

        e1 = Math.exp(z1 * delta_time)
        e2 = Math.exp(z2 * delta_time)

        inv_two_zb = 1.0 / (2.0 * zb)

        e1_over_two_zb = e1 * inv_two_zb
        e2_over_two_zb = e2 * inv_two_zb

        z1_e1_over_two_zb = z1 * e1_over_two_zb
        z2_e2_over_two_zb = z2 * e2_over_two_zb

        @pos_pos_coef = e1_over_two_zb * z2 - z2_e2_over_two_zb + e2
        @pos_vel_coef = -e1_over_two_zb + e2_over_two_zb

        @vel_pos_coef = (z1_e1_over_two_zb - z2_e2_over_two_zb + e2) * z2
        @vel_vel_coef = -z1_e1_over_two_zb + z2_e2_over_two_zb
      elsif damping_ratio < 1.0 - EPSILON
        omega_zeta = angular_frequency * damping_ratio
        alpha = angular_frequency * Math.sqrt(1.0 - damping_ratio * damping_ratio)

        exp_term = Math.exp(-omega_zeta * delta_time)
        cos_term = Math.cos(alpha * delta_time)
        sin_term = Math.sin(alpha * delta_time)

        inv_alpha = 1.0 / alpha

        exp_sin = exp_term * sin_term
        exp_cos = exp_term * cos_term
        exp_omega_zeta_sin_over_alpha = exp_term * omega_zeta * sin_term * inv_alpha

        @pos_pos_coef = exp_cos + exp_omega_zeta_sin_over_alpha
        @pos_vel_coef = exp_sin * inv_alpha

        @vel_pos_coef = -exp_sin * alpha - omega_zeta * exp_omega_zeta_sin_over_alpha
        @vel_vel_coef = exp_cos - exp_omega_zeta_sin_over_alpha
      else
        exp_term = Math.exp(-angular_frequency * delta_time)
        time_exp = delta_time * exp_term
        time_exp_freq = time_exp * angular_frequency

        @pos_pos_coef = time_exp_freq + exp_term
        @pos_vel_coef = time_exp

        @vel_pos_coef = -angular_frequency * time_exp_freq
        @vel_vel_coef = -time_exp_freq + exp_term
      end
    end

    def update(pos : Float64, vel : Float64, equilibrium_pos : Float64) : {Float64, Float64}
      old_pos = pos - equilibrium_pos
      old_vel = vel

      new_pos = old_pos * @pos_pos_coef + old_vel * @pos_vel_coef + equilibrium_pos
      new_vel = old_pos * @vel_pos_coef + old_vel * @vel_vel_coef

      {new_pos, new_vel}
    end
  end

  class Projectile
    @pos : Point
    @vel : Vector
    @acc : Vector
    @delta_time : Float64

    def initialize(delta_time : Float64, initial_position : Point, initial_velocity : Vector, initial_acceleration : Vector)
      @pos = initial_position
      @vel = initial_velocity
      @acc = initial_acceleration
      @delta_time = delta_time
    end

    def update : Point
      @pos = Point.new(
        @pos.x + (@vel.x * @delta_time),
        @pos.y + (@vel.y * @delta_time),
        @pos.z + (@vel.z * @delta_time),
      )

      @vel = Vector.new(
        @vel.x + (@acc.x * @delta_time),
        @vel.y + (@acc.y * @delta_time),
        @vel.z + (@acc.z * @delta_time),
      )

      @pos
    end

    def position : Point
      @pos
    end

    def velocity : Vector
      @vel
    end

    def acceleration : Vector
      @acc
    end
  end
end
