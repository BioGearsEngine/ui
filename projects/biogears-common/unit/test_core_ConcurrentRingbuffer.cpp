//! Copyright (C) Applied Research Associates - All Rights Reserved
//! Unauthorized copying of this file, via any medium is strictly prohibited
//! Proprietary and confidential
//!
//! This file is subject to the terms and conditions defined in file
//! 'LICENSE.txt', which is part of this source code package

//!
//! @author David Lee
//! @date   2017 Aug 3rd
//!
//! Unit Test for NGSS Config
//!
#include <thread>
#include <functional>
#include <future>

#include <gtest/gtest.h>

#include <ara/container/concurrent_ringbuffer.tci.h>

#ifdef DISABLE_KALE_ConcurrentRingbuffer_TEST
  #define TEST_FIXTURE_NAME DISABLED_ConcurrentRingbufferFixture
#else
  #define TEST_FIXTURE_NAME ConcurrentRingbufferFixture
#endif


// The fixture for testing class Foo.
class TEST_FIXTURE_NAME : public ::testing::Test {
protected:
  // You can do set-up work for each test here.
  TEST_FIXTURE_NAME() = default;

  // You can do clean-up work that doesn't throw exceptions here.
  virtual ~TEST_FIXTURE_NAME() = default;

  // If the constructor and destructor are not enough for setting up
  // and cleaning up each test, you can define the following methods:

  // Code here will be called immediately after the constructor (right
  // before each test).
  virtual void SetUp();

  // Code here will be called immediately after each test (right
  // before the destructor).
  virtual void TearDown();
};

void TEST_FIXTURE_NAME::SetUp()
{
}

void TEST_FIXTURE_NAME::TearDown()
{

}

TEST_F(TEST_FIXTURE_NAME, ConcurrentRingbuffer_push_pop)
{
  using  ara::ConcurrentRingbuffer;
  ConcurrentRingbuffer<int> queue(5);

  for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {

    if ( i < 5) {
      EXPECT_EQ(i, queue.unsafe_size());
      EXPECT_FALSE(queue.insert(i));
    } else {
      EXPECT_EQ(5, queue.unsafe_size());
      EXPECT_TRUE(queue.insert(i));
    }
  }

  for (auto i : { 5, 6, 7, 8, 9 }) {
    EXPECT_EQ(10 - i, queue.unsafe_size());
    EXPECT_EQ(i, queue.consume());
  }
}

TEST_F(TEST_FIXTURE_NAME, ConcurrentRingbuffer_active)
{
  using  ara::ConcurrentRingbuffer;
  ConcurrentRingbuffer<int> queue;


  EXPECT_TRUE(queue.active());
  queue.abort();
  EXPECT_TRUE(queue.active());
  queue.shutdown();
  EXPECT_FALSE(queue.active());

}

TEST_F(TEST_FIXTURE_NAME, ConcurrentRingbuffer_block_pop)
{
  using  ara::ConcurrentRingbuffer;
  ConcurrentRingbuffer<int> queue;

  auto future = std::async(std::launch::async
  , [&queue]() {
    for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
      std::this_thread::sleep_for(std::chrono::milliseconds(16));
      queue.insert(i);
    }

  });
  for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
    EXPECT_EQ(0, queue.unsafe_size());
    EXPECT_EQ(i, queue.consume());
  }

  EXPECT_TRUE(queue.active());
  queue.abort();
  EXPECT_TRUE(queue.active());
  queue.shutdown();
  EXPECT_FALSE(queue.active());

}

TEST_F(TEST_FIXTURE_NAME, ConcurrentRingbuffer_shutdown)
{
  using  ara::ConcurrentRingbuffer;
  ConcurrentRingbuffer<int> queue;

  auto push = std::async(std::launch::async
  , [&queue]() {
    for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
      std::this_thread::sleep_for(std::chrono::milliseconds(16));
      EXPECT_FALSE(queue.insert(i));
    }

  });

  auto shutdown = std::async(std::launch::async
  , [&queue]() {
    std::this_thread::sleep_for(std::chrono::milliseconds(48));
    queue.shutdown();
    EXPECT_FALSE(queue.active()); //< No Overflow
  });

  int value = 0;
  for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
    EXPECT_EQ(0, queue.unsafe_size());
    value = 10;
    queue.consume(value);
    if (value != 10) {
      EXPECT_EQ(i, value);
    }
  }

  EXPECT_FALSE(queue.active());

}

TEST_F(TEST_FIXTURE_NAME, ConcurrentRingbuffer_no_move)
{

	using  ara::ConcurrentRingbuffer;
	ConcurrentRingbuffer< std::unique_ptr<double> > queue;

	auto push = std::async(std::launch::async
		, [&queue]() {
		for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
			std::this_thread::sleep_for(std::chrono::milliseconds(16));
			EXPECT_FALSE(queue.insert( std::make_unique<double>(i) ));
		}

	});

	auto shutdown = std::async(std::launch::async
		, [&queue]() {
		std::this_thread::sleep_for(std::chrono::milliseconds(48));
		queue.shutdown();
		EXPECT_FALSE(queue.active()); //< No Overflow
	});

	auto value = std::make_unique<double>(10);
	for (auto i : { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }) {
		value = queue.consume();
		if ( value )
		{
			EXPECT_EQ(i, *value);
		}
	}

	EXPECT_FALSE(queue.active());

}

