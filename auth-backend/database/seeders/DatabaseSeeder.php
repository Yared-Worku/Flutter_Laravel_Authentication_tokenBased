<?php

namespace Database\Seeders;

use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // 1. Seed Roles first
        $this->call([
            RoleSeeder::class,
        ]);

        // 2. Safely find or create the user
        $adminUser = User::firstOrCreate(
            ['email' => 'yared@example.com'],
            [
                'name' => 'Yared',
                'password' => 'yared123', // Automatically hashed by User model casts
            ]
        );

        // 3. Sync 'admin' role without throwing duplicate pivot errors
        $adminRole = Role::where('name', 'admin')->first();
        if ($adminRole) {
            $adminUser->roles()->syncWithoutDetaching([$adminRole->id]);
        }
    }
}