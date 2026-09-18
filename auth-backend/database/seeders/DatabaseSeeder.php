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
        //Seed Roles first
        $this->call([
            RoleSeeder::class,
        ]);

        // Safely find or create the user
        $adminUser = User::firstOrCreate(
            ['email' => 'yared@example.com'],
            [
                'name' => 'Yared',
                'password' => 'yared123', // Automatically hashed by User model casts
            ]
        );

        // Sync 'admin' role without throwing duplicate pivot errors
        $adminRole = Role::where('name', 'admin')->first();
        if ($adminRole) {
            $adminUser->roles()->syncWithoutDetaching([$adminRole->id]);
        }
    }
}
