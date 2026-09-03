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

        // 2. Create the Test User
        $adminUser = User::factory()->create([
            'name' => 'yared',
            'email' => 'yared@example.com',
            'password' => 'yared123', 
        ]);

        // 3. Attach 'admin' role using Eloquent relationship
        $adminRole = Role::where('name', 'admin')->first();
        if ($adminRole) {
            $adminUser->roles()->attach($adminRole->id);
        }
    }
}